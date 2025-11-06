# lambda function

resource "aws_lambda_function" "name-2" {

  function_name    = "lambda_function"
  role             = aws_iam_role.name-2.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  timeout          = 900
  filename         = "C:\\Users\\tubaa\\OneDrive\\Desktop\\terraform\\file-10\\lambda_function.zip"
  source_code_hash = filebase64sha256("C:\\Users\\tubaa\\OneDrive\\Desktop\\terraform\\file-10\\lambda_function.zip")
  #function name, handler name and file name should be same 

}
# requires iam role  - assume role

resource "aws_iam_role" "name-2" {
  name = "test_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : "sts:AssumeRole",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      }
    }]
  })
}

#role association
resource "aws_iam_role_policy_attachment" "name-2" {
  role       = aws_iam_role.name-2.name
  policy_arn = aws_iam_policy.name-2.arn
}

#policy creation
resource "aws_iam_policy" "name-2" {
  name = "lambda_policy"
  path = "/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : "lambda:InvokeFunction",
      "Resource" : "*",
    }]
  })
}

resource "aws_iam_instance_profile" "name-2" {
  name = "test_profile"
  role = aws_iam_role.name-2.name
}


#cloudwatch event rule
resource "aws_cloudwatch_event_rule" "name-2" {
  name                = "test_every_minute"
  description         = "test"
  schedule_expression = "rate(1 minute)"

}
#cloudwatch target
resource "aws_cloudwatch_event_target" "name-2" {
  rule      = aws_cloudwatch_event_rule.name-2.name
  target_id = aws_lambda_function.name-2.id
  arn       = aws_lambda_function.name-2.arn
}


# permissions

resource "aws_lambda_permission" "event_bridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.name-2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.name-2.arn
}

#	- Iam policy document
resource "aws_iam_policy" "name-3" {
  name = "cloud-watch-logging"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource" : "arn:aws:logs:*:*:*",
    }]
  })
}

#- Iam policy attachment
resource "aws_iam_policy_attachment" "name-3" {
  name = "attach-logging-policy-attacchment"
  roles       = [aws_iam_role.name-2.name]
  policy_arn = aws_iam_policy.name-3.arn
}

