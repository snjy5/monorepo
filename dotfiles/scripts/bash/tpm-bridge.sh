#!/bin/bash
# Firefox Native Messaging uses a 4-byte buffer length prefix for stdio

# 1. Read incoming data from Firefox
read -N 4 length_bytes
# Convert raw bytes to integer length
length=$(printf "%d" "0x$(xxd -p <<< "$length_bytes")")
read -N $length json_input

# 2. Extract the challenge from the JSON (assumes jq is installed)
# Google sends a base64url encoded challenge
CHALLENGE_B64=$(echo "$json_input" | jq -r '.challenge')

# 3. Clean the base64 string and decode it to binary
CHALLENGE_RAW=$(echo "$CHALLENGE_B64" | tr '_-' '/+' | awk '{string=$0; len=length(string)%4; if(len==2){string=string"=="}else if(len==3){string=string"="} print string}')
echo "$CHALLENGE_RAW" | base64 -d > /tmp/challenge.bin

# 4. CRITICAL STEP: Talk to the Hardware TPM
# We use primary keys under the storage hierarchy to sign the data
tpm2_createprimary -C o -c /tmp/primary.ctx
tpm2_sign -c /tmp/primary.ctx -g sha256 -o /tmp/sig.bin /tmp/challenge.bin

# 5. Encode the real hardware signature back to base64
SIGNATURE_B64=$(base64 -w 0 /tmp/sig.bin | tr '/+' '_-' | tr -d '=')

# 6. Format the WebAuthn-compliant JSON payload Google expects
RESPONSE_JSON=$(jq -n \
  --arg sig "$SIGNATURE_B64" \
  --arg chal "$CHALLENGE_B64" \
  '{"signature": $sig, "challenge": $chal, "authenticatorData": "SZYN5YgOjGh0NBcP51AXbOCYSk4aff4cRAAAAAE", "clientDataType": "webauthn.get"}')

# 7. Write back to Firefox with the 4-byte length header
OUTPUT_LEN=${#RESPONSE_JSON}
printf "$(printf '\\x%08x' $OUTPUT_LEN | sed 's/\(..\)\(..\)\(..\)\(..\)/\\x\4\\x\3\\x\2\\x\1/')%s" "$RESPONSE_JSON"
