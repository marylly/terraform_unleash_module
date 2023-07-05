locals {
    toggles_list = flatten([
        for service, toggles in var.toggles_list_entries : [
            for toggle in toggles : merge(toggle, {
                service = service,
                variants = toggle.variants != "" ? jsondecode(file("./domains/profiles/variants/${toggle.variants}")) : []
            })
    ]])
}

data "unleash_project" "unleash_project" {
  project_id = "default"
}

resource "unleash_feature" "feature_toggles" {
    for_each   = { for toggle in local.toggles_list : "${toggle.service}-${toggle.toggle_name}" => toggle }
    name       = each.value.toggle_name
    project_id = data.unleash_project.unleash_project.project_id
    type       = each.value.strategy_type

    dynamic "variant" {
      for_each = each.value.variants
      content {
        name = variant.value.name
        weight_type = variant.value.weightType
        weight = variant.value.weight
        stickiness = variant.value.stickiness
        payload {
            type  = variant.value.payload["type"]
            value = variant.value.payload["value"]
        }
        overrides {
            context_name = each.value.toggle_name
            values = variant.value.overrides
        }
      }  
    }
}

resource "unleash_strategy_assignment" "feature_toggles_strategies" {
    for_each      = { for toggle in local.toggles_list : "${toggle.service}-${toggle.toggle_name}" => toggle }
    feature_name  = each.value.toggle_name
    project_id    = data.unleash_project.unleash_project.project_id
    environment   = "default"
    strategy_name = each.value.strategy_type
    parameters = {
        rollout    = "68"
        stickiness = "random"
        groupId    = "toggle"
    }
}