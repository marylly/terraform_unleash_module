variable "toggles_list_entries" {
    description = "List of feature toggle to be created/updated"
    type = map(
        list(
            object({
                toggle_name     = string,
                strategy_type   = string, #release, flexibleRollout
                variants        = optional(string)
            })
        )
    )
}