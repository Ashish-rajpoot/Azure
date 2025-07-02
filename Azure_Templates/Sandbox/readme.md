az deployment group create \
 --resource-group learn-0cae6d71-f196-4ad1-a990-bf521ad4ae71 \
 --template-file template.json \
 --parameters @parameters.json
