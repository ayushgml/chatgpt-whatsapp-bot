# Standard library import
import logging
from decouple import config

# Third-party imports
from twilio.rest import Client


account_sid = config("TWILIO_ACCOUNT_SID")
auth_token = config("TWILIO_AUTH_TOKEN")
client = Client(account_sid, auth_token)
twilio_number = config("TWILIO_NUMBER")

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Sending message logic through Twilio Messaging API
def send_message(to_number, body_text):
    """
    Sends a WhatsApp message to the specified phone number.

    Parameters:
    - to_number (str): The phone number to send the message to.
    - body_text (str): The text of the message to send.

    Returns:
    None
    """
    try:
        # Split the body_text into substrings of 1600 characters or less
        max_length = 1600
        message_parts = [body_text[i:i+max_length] for i in range(0, len(body_text), max_length)]

        # Loop through each substring and send a message
        for part in message_parts:
            message = client.messages.create(
                from_=f"whatsapp:{twilio_number}",
                body=part,
                to=f"whatsapp:{to_number}"
            )
            logger.info(f"Message sent to {to_number}: {message.body}")
    except Exception as e:
        logger.error(f"Error sending message to {to_number}: {e}")

