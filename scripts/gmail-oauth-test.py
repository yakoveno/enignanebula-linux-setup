"""
Gmail OAuth Test Script for EnigmaNebula

This script demonstrates how to use OAuth credentials to send emails via Gmail API.
"""

import os
import pickle
import base64
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from google.auth.transport.requests import Request
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# Scopes required for sending emails
SCOPES = ['https://www.googleapis.com/auth/gmail.send']

def authenticate_gmail():
    """Authenticate with Gmail using OAuth"""
    creds = None
    
    # Token file stores the user's access and refresh tokens
    if os.path.exists('token.json'):
        with open('token.json', 'rb') as token:
            creds = pickle.load(token)
    
    # If there are no (valid) credentials available, let the user log in
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            # Load the credentials from the downloaded file
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        
        # Save the credentials for the next run
        with open('token.json', 'wb') as token:
            pickle.dump(creds, token)
    
    return build('gmail', 'v1', credentials=creds)

def create_message(sender, to, subject, message_text):
    """Create a message for an email"""
    message = MIMEMultipart()
    message['from'] = sender
    message['to'] = to
    message['subject'] = subject
    message.attach(MIMEText(message_text, 'plain'))
    
    raw_message = base64.urlsafe_b64encode(message.as_bytes()).decode('utf-8')
    return {'raw': raw_message}

def send_email(service, user_id, message):
    """Send an email message"""
    try:
        message = service.users().messages().send(userId=user_id, body=message).execute()
        print(f'Message Id: {message["id"]}')
        return message
    except Exception as error:
        print(f'An error occurred: {error}')
        return None

def main():
    print("EnigmaNebula Gmail OAuth Test")
    print("=" * 40)
    
    # Authenticate and get the service object
    service = authenticate_gmail()
    
    # Create a test message
    sender = "enignanebula.ai.agent@gmail.com"
    recipient = "yakoveno.alex@gmail.com"
    subject = "Test from EnigmaNebula"
    body = "Hey Alex,\n\nThis is a test message from EnigmaNebula using Gmail OAuth!\n\nBest regards,\nEnigmaNebula"
    
    message = create_message(sender, recipient, subject, body)
    
    # Send the email
    result = send_email(service, "me", message)
    
    if result:
        print("Email sent successfully!")
    else:
        print("Failed to send email.")

if __name__ == '__main__':
    main()