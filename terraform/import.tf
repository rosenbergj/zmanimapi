import {
  to = aws_s3_bucket.lambda_packages
  id = "zmanim-api-packages"
}

import {
  to = aws_iam_role.lambda_exec
  id = "ZmanimAPI-role-2b8cuuvq"
}

import {
  to = aws_cloudwatch_log_group.lambda
  id = "/aws/lambda/ZmanimAPI"
}

import {
  to = aws_lambda_function.api
  id = "ZmanimAPI"
}

import {
  to = aws_api_gateway_rest_api.api
  id = "524bustw55"
}

import {
  to = aws_api_gateway_request_validator.query_params
  id = "524bustw55/itcv2y"
}

import {
  to = aws_api_gateway_method.root_get
  id = "524bustw55/ld6abwx31h/GET"
}

import {
  to = aws_api_gateway_integration.root_get
  id = "524bustw55/ld6abwx31h/GET"
}

import {
  to = aws_api_gateway_deployment.api
  id = "524bustw55/9igka6"
}

import {
  to = aws_api_gateway_stage.production
  id = "524bustw55/production"
}

import {
  to = aws_lambda_permission.apigw
  id = "ZmanimAPI/6bd11508-09f7-4098-aaa8-9e9071dbb08f"
}

import {
  to = aws_api_gateway_domain_name.zmanapi
  id = "api.zmanapi.com"
}

import {
  to = aws_api_gateway_domain_name.zmanimapi
  id = "api.zmanimapi.com"
}

import {
  to = aws_api_gateway_domain_name.amishabbatornot
  id = "api.amishabbatornot.com"
}

import {
  to = aws_api_gateway_base_path_mapping.zmanapi
  id = "api.zmanapi.com/"
}

import {
  to = aws_api_gateway_base_path_mapping.zmanimapi
  id = "api.zmanimapi.com/"
}

import {
  to = aws_api_gateway_base_path_mapping.amishabbatornot
  id = "api.amishabbatornot.com/"
}
