import os
import requests

# ==============================
# MessageCentral Config
# ==============================

MESSAGECENTRAL_AUTH_TOKEN = os.getenv("MESSAGE_CENTRAL_AUTH_TOKEN")
MESSAGECENTRAL_CUSTOMER_ID = os.getenv("MESSAGE_CENTRAL_CUSTOMER_ID")

BASE_URL = "https://cpaas.messagecentral.com"


# ==============================
# SEND OTP  ✅ CORRECT FORMAT
# ==============================

def send_otp(mobile: str):
    print("AUTH TOKEN:", MESSAGECENTRAL_AUTH_TOKEN)
    print("CUSTOMER ID:", MESSAGECENTRAL_CUSTOMER_ID)

    if not MESSAGECENTRAL_AUTH_TOKEN or not MESSAGECENTRAL_CUSTOMER_ID:
        return {
            "success": False,
            "message": "MessageCentral credentials missing"
        }

    url = f"{BASE_URL}/verification/v3/send"

    params = {
        "countryCode": "91",
        "customerId": MESSAGECENTRAL_CUSTOMER_ID,
        "flowType": "SMS",
        "mobileNumber": mobile
    }

    headers = {
        "authToken": MESSAGECENTRAL_AUTH_TOKEN
    }

    response = requests.post(url, params=params, headers=headers)

    print("SEND OTP STATUS:", response.status_code)
    print("SEND OTP RESPONSE:", response.text)

    with open("otp_debug.txt", "a") as f:
        f.write(f"\n--- SEND OTP ---\n")
        f.write(f"Mobile: {mobile}\n")
        f.write(f"Token present: {bool(MESSAGECENTRAL_AUTH_TOKEN)}\n")
        f.write(f"Customer ID present: {bool(MESSAGECENTRAL_CUSTOMER_ID)}\n")
        f.write(f"Status: {response.status_code}\n")
        f.write(f"Response: {response.text}\n")

    if response.status_code != 200:
        return {
            "success": False,
            "message": "OTP send failed",
            "raw_response": response.text
        }

    try:
        data = response.json()
    except Exception:
        return {
            "success": False,
            "message": "Invalid JSON from OTP service",
            "raw_response": response.text
        }

    verification_id = data.get("data", {}).get("verificationId")

    if not verification_id:
        return {
            "success": False,
            "message": "verificationId missing",
            "raw_response": data
        }

    return {
        "success": True,
        "verification_id": verification_id
    }


# ==============================
# VERIFY OTP  ✅ CORRECT FORMAT
# ==============================

def verify_otp(mobile: str, otp: str, verification_id: str):
    url = f"{BASE_URL}/verification/v3/validateOtp"

    params = {
        "customerId": MESSAGECENTRAL_CUSTOMER_ID,
        "verificationId": verification_id,
        "code": otp
    }

    headers = {
        "authToken": MESSAGECENTRAL_AUTH_TOKEN
    }

    # Debugging revealed GET works better than POST for this endpoint
    response = requests.get(url, params=params, headers=headers)

    print("VERIFY OTP STATUS:", response.status_code)
    print("VERIFY OTP RESPONSE:", response.text)

    if response.status_code != 200:
        return {
            "success": False,
            "message": f"OTP verification failed (Status {response.status_code}): {response.text}",
            "raw_response": response.text
        }

    if not response.text.strip():
        return {
            "success": False,
            "message": "Empty response from OTP service"
        }

    try:
        data = response.json()
    except Exception:
        return {
            "success": False,
            "message": "Invalid response format",
            "raw_response": response.text
        }

    status = data.get("data", {}).get("verificationStatus")
    if status == "VERIFIED" or status == "VERIFICATION_COMPLETED":
        return {
            "success": True,
            "message": "OTP verified successfully"
        }

    return {
        "success": False,
        "message": "Invalid OTP"
    }

