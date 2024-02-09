{ config
, lib
, pkgs
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.formatters;
in
{
  options.vim.formatters = {
    enable = mkEnableOption "";
    default = true;
    packages = {
      leptosfmt = mkPackageOption pkgs [ "leptosfmt package to use" ] {
        default = [ "leptosfmt" ];
      };
    };

    conform = {
      #use plugin conformer.nvim
      enable = mkOption {
        description = "conform.nvim";
        type = types.bool;
        default = true;
      };
    };

    # How to install a system package here like leptosfmt
  };
  # setup leptosfmt with conformer.nvim
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.conform.enable {
      vim.startPlugins = [ "conform" ];
      vim.luaConfigRC.fmtconfig =
        nvim.dag.entryAfter [ "lsp-setup" ]
          /*
        lua
          */
          ''
            require("conform").setup({
              formatters_by_ft = {
                rust = {"leptosfmt"},
              },
              formatters = {
                leptosfmt = {
                  command = "${pkgs.leptosfmt}/bin",
                },
              },
              format_on_save = {
                lsp_fallback = true,
                timeout_ms = 500,
              },
            })
            require("conform").formatters.leptosfmt = {
              inherit = false,
              command ="leptosfmt",
              args = {"-s"};
            }
          '';
    })
  ]);
}
