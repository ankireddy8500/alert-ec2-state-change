resource "aws_cloudwatch_event_rule" "EventRule" {
  name = "EC2-state-change"
  description = "A CloudWatch Event Rule that detects changes to EC2 Instances and publishes change events to an SNS topic for notification."
  is_enabled = true
  event_pattern = <<PATTERN
{
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "ec2.amazonaws.com"
    ],
    "eventName": [
      "RunInstances",
      "RebootInstances",
      "StartInstances",
      "StopInstances",
      "TerminateInstances"
    ]
  }
}
PATTERN

}

resource "aws_cloudwatch_event_target" "TargetForEventRule" {
  rule = aws_cloudwatch_event_rule.EventRule.name
#   target_id = "SendToSNS"
  arn = aws_sns_topic.alerts_ec2_state_change.arn

  input_transformer {
    input_paths = {
        "instance":"$.detail.requestParameters.instancesSet.items", 
        "status":"$.detail.eventName", 
        # "state":"$.detail.responseElements.instancesSet.items",
        "time":"$.detail.eventTime", 
        "region":"$.detail.awsRegion", 
        "account":"$.account"
        }
    input_template = "\"At   '<time>' , the event   '<status>'   occured & the details of your EC2 instance undergone state change on account    '<account>'    in the AWS Region    '<region>' are  '<instance>' \""

}

}