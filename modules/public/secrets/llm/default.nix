{
  config,
  pkgs,
  username,
  ...
}: let
  llmConfigFolder =
    if pkgs.stdenv.isDarwin
    then "Library/Application Support/io.datasette.llm"
    else ".config/io.datasette.llm";
  secretPath = config.sops.secrets."llm-keys".path;
  extraModelsPath = config.sops.secrets."llm-extra-models".path;
in {
  sops.secrets."llm-keys" = {
    sopsFile = ./keys.json;
    format = "binary";
    owner = username;
    mode = "0400";
  };
  sops.secrets."llm-extra-models" = {
    sopsFile = ./extra-openai-models.yaml;
    format = "binary";
    owner = username;
    mode = "0400";
  };

  home-manager.users.${username} = {config, ...}: {
    home.file."${llmConfigFolder}/keys.json".source =
      config.lib.file.mkOutOfStoreSymlink secretPath;
    home.file."${llmConfigFolder}/extra-openai-models.yaml".source =
      config.lib.file.mkOutOfStoreSymlink extraModelsPath;
  };
}
