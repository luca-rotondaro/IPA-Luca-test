# _            _  _           _  _  _  _  _                    _           _  _  _      
#(_)          (_)(_) _     _ (_)(_)(_)(_)(_) _               _(_)_      _ (_)(_)(_) _   
#(_)          (_)(_)(_)   (_)(_) (_)        (_)            _(_) (_)_   (_)         (_)  
#(_)          (_)(_) (_)_(_) (_) (_) _  _  _(_)          _(_)     (_)_ (_)    _  _  _   
#(_)          (_)(_)   (_)   (_) (_)(_)(_)(_)_          (_) _  _  _ (_)(_)   (_)(_)(_)  
#(_)          (_)(_)         (_) (_)        (_)         (_)(_)(_)(_)(_)(_)         (_)  
#(_)_  _  _  _(_)(_)         (_) (_)_  _  _ (_)         (_)         (_)(_) _  _  _ (_)  
#  (_)(_)(_)(_)  (_)         (_)(_)(_)(_)(_)            (_)         (_)   (_)(_)(_)(_)  

#Creator: luca.rotondaro@umb.ch
#FileName: terraform.tf
#Date: 17.04.2022
#Description: main file für Azure Test Lab umgebung
#-->

#Cost Management and Notifications

resource "azurerm_monitor_action_group" "management" {
  name                = "sub-budget-${local.local_data.result.customer.shortName}"
  resource_group_name = azurerm_resource_group.management.name
  short_name          = "agroup-${local.local_data.result.customer.shortName}"
}

resource "azurerm_consumption_budget_resource_group" "management" {
  name              = "sub-budget-${local.local_data.result.customer.shortName}"
  resource_group_id = azurerm_resource_group.management.id

  amount     = local.local_data.result.customer.budget
  time_grain = "Monthly"

  time_period {
    start_date = "${local.local_data.result.azure.start_date}Z"
    end_date   = "${local.local_data.result.azure.end_date}Z"
  }

  filter {
    tag {
      name = "Monitoring-${local.local_data.result.customer.shortName}"
      values = [
        local.local_data.result.customer.shortName,
      ]
    }
  }

  notification {
    enabled        = true
    threshold      = 50.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_emails = [
      local.local_data.result.customer.email,
      var.creator,
    ]

    contact_groups = [
      azurerm_monitor_action_group.management.id,
    ]

    contact_roles = [
      "owner",
    ]
  }

  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_emails = [
      local.local_data.result.customer.email,
      var.creator,
    ]

    contact_groups = [
      azurerm_monitor_action_group.management.id,
    ]

    contact_roles = [
      "owner",
    ]
  }
  notification {
    enabled        = true
    threshold      = 95.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_emails = [
      local.local_data.result.customer.email,
      var.creator,
    ]

    contact_groups = [
      azurerm_monitor_action_group.management.id,
    ]

    contact_roles = [
      "owner",
    ]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_emails = [
      local.local_data.result.customer.email,
      var.creator,
    ]

    contact_groups = [
      azurerm_monitor_action_group.management.id,
    ]

    contact_roles = [
      "owner",
    ]
  }
}