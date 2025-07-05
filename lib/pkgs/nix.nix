{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    inputs.nil_ls.outputs.packages.${pkgs.system}.nil
  ];
}
