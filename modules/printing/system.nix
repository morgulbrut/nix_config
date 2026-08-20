{ pkgs, ... }:
{
  services.printing.drivers = with pkgs; [
    gutenprint       # broad generic PCL/PS + inkjet support
    canon-cups-ufr2  # fallback if driverless/IPP-Everywhere doesn't cover this model
  ];

  environment.systemPackages = [
    pkgs.system-config-printer
  ];
}
