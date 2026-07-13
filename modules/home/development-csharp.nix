{ pkgs, ... }:

{
  home.packages = with pkgs; [
    dotnet-sdk_10
    csharp-ls
  ];
}
