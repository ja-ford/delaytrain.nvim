vim.api.nvim_create_user_command("DelayTrainEnable", function()
    require("delaytrain").enable()
end, { desc = "Enable DelayTrain by setting defined keymaps" })

vim.api.nvim_create_user_command("DelayTrainDisable", function()
    require("delaytrain").disable()
end, { desc = "Disable DelayTrain by deleting defined keymaps" })

vim.api.nvim_create_user_command("DelayTrainToggle", function()
    require("delaytrain").toggle()
end, { desc = "Toggle DelayTrain by setting/deleting keymaps" })
