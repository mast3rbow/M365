import adal
import json
import requests
import logging

FROM_EMAIL = 'sender@example.com'
TENANT_ID = 'f01737c6-9208-4ef0-8ba3-8636e1f0ab36'
CLIENT_ID = '04391657-a342-43d6-9660-0f351df7cef0'
CLIENT_SECRET = '038fe324-7073-4892-b4f3-ece8012a113b'
TARGET_EMAIL = 'ben.smith@tbtcsanorth.com.au'
URL = 'https://prod-45.westus.logic.azure.com:443/workflows/1e3a3b4e4e5c4d7a9b8a9b9b9b9b9b9b/triggers/manual/paths/invoke?api-version=2016-06-0'

def get_access_token(tenant_id, client_id, client_secret):
    """
    Uses the ADAL library to get an access token for the Microsoft Graph API.
    """
    resource_URL ='https://graph.microsoft.com'
    authority_url = f'https://login.microsoftonline.com/{tenant_id}'

    context = adal.AuthenticationContext(authority_url)

    token = context.acquire_token_with_client_credentials(
        resource_URL,
        client_id,
        client_secret,
    )

    return token['accessToken']

def send_logic_app(message, url):
    """
    Sends a JSON API post to the LogicApp or 365 App
    """
    headers = {'Content-Type': 'application/json'}
    data = json.dumps(message)

    response = requests.post(url, headers=headers, data=data)
    
    if response.status_code == 200:
        logging.info('Message sent successfully')
    else: 
        logging.error('Error occured' + response.status_code)
    return response

def get_sharepoint_useage(access_token):
    """
    Gets the current usage of SharePoint Online, by connecting to the base Site API.
    SHOULD BE IMPROVIDED TO GET ALL SITES AND LOOP THROUGH EACH ONE
    WILL NEED TO HANDLE ONEDRIVE SITES ETC
    """
    url = 'https://graph.microsoft.com/v1.0/sites/root'
    headers = {'Authorization': f'Bearer {access_token}'}
    r = requests.get(url, headers=headers)
    
    max_quota = r['usage']['quota']
    current_usage = r['usage']['used']
    usage_percentage = (current_usage / max_quota) * 100
    thresholds = [85, 90, 95]

    print(max_quota)
    print(current_usage)

    for threshold in thresholds:
        print(threshold)
        if usage_percentage >= threshold:
            subject = f'SharePoint usage alert: {threshold}% reached'
            body = f'Your SharePoint usage has reached {usage_percentage:.2f}% of the maximum quota ({current_usage}/{max_quota}).'
            message = json.dumps({
                subject: subject,
                body: body
            })
            send_logic_app(message, URL)