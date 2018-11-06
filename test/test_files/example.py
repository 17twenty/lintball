"""
  Lambda Handler: post sns to slack

  Environment variables:
    channel: string, required - Slack Channel SNS will post to
    webhool_url: string, required - Slack API webhook

"""

import os
import requests

from lib.slack_formatter import (
    slack_json_payload,
    approval_message_format,
    change_log_message_format
)


def lambda_handler(event, _):
    """ post SNS to slack """

    channel = os.environ['channel']
    webhook_url = os.environ['slack_endpoint']
    sns = event['Records'][0]['Sns']
    subject = sns['Subject']
    message = sns['Message']

    if subject.startswith('APPROVAL NEEDED'):

        print "APPROVAL NEEDED event triggered"
        formatted_message = approval_message_format(message)
        payload = slack_json_payload(channel, subject, formatted_message)

        response = requests.post(webhook_url, json=payload)
        return response.status_code

    if subject.startswith('Ready for approval'):

        print "Ready for approval event triggered"
        formatted_message = change_log_message_format(message)
        payload = slack_json_payload(channel, subject, formatted_message)

        response = requests.post(webhook_url, json=payload)
        return response.status_code


    print "SNS topic didn't trigger an event"
    # pylint - R1710 - either all return statements in a function should return an expression,
    # or none of them should.
    return ""
