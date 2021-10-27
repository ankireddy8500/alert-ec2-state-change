data "aws_caller_identity" "current" {
}

resource "aws_sns_topic" "alerts_ec2_state_change" {
  name = "alerts-EC2-state-change"
  display_name = "Alert-EC2-State-Changed"
}

data "aws_iam_policy_document" "topic-policy-PolicyForSnsTopic" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.alerts_ec2_state_change.arn
    ]

    sid = "__default_statement_ID"
  }
  
  statement {
    actions = [
      "sns:Publish"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.alerts_ec2_state_change.arn
    ]

    sid = "TrustCWEToPublishEventsToMyTopic"
  }
}

resource "aws_sns_topic_policy" "PolicyForSnsTopic" {
  arn = aws_sns_topic.alerts_ec2_state_change.arn
  policy = data.aws_iam_policy_document.topic-policy-PolicyForSnsTopic.json
}

resource "aws_sns_topic_subscription" "user_updates_email_target" {
  topic_arn = aws_sns_topic.alerts_ec2_state_change.arn
  protocol  = "email"
  endpoint  = "ankireddy8500@.com"
}