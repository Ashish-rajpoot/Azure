az appservice plan create `
    --resource-group "myResourceGroup" `
    --name "myAppServicePlan" `
    --is-linux true `
    --sku B1

az webapp create `
    --resource-group "" `
    --name "" `
    --plan "" `
    --os-type "" `
    --runtime ""