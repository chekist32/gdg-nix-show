{ pkgs, config, ... }:
{
  # WordPress CLI for managing WordPress from the command line
  packages = [
    pkgs.wp-cli
  ];

  languages.php = {
    enable = true;
    version = "8.4";

    # PHP extensions required by WordPress
    # Note: common extensions like xml, mbstring, curl are enabled by default
    extensions = [
      "mysqli" # MySQL database connectivity
      "pdo_mysql" # PDO MySQL driver (used by some plugins)
      "gd" # Image manipulation (thumbnails, image editing)
      "zip" # Plugin/theme installation from zip files
      "intl" # Internationalization support
      "exif" # Image metadata reading
    ];

    # PHP settings for WordPress
    ini = ''
      memory_limit = 256M
      upload_max_filesize = 64M
      post_max_size = 64M
      max_execution_time = 300
    '';

    # PHP-FPM pool configuration
    # FPM (FastCGI Process Manager) manages PHP worker processes
    fpm.pools.web = {
      settings = {
        "pm" = "dynamic"; # Dynamic process management
        "pm.max_children" = 10; # Maximum worker processes
        "pm.start_servers" = 2; # Workers to start initially
        "pm.min_spare_servers" = 1; # Minimum idle workers
        "pm.max_spare_servers" = 5; # Maximum idle workers
      };
    };
  };

  # MariaDB database server
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

    # Create the WordPress database on first run
    initialDatabases = [ { name = "wordpress"; } ];

    # Create database user with access to WordPress database
    ensureUsers = [
      {
        name = "wordpress";
        password = "wordpress";
        ensurePermissions = {
          "wordpress.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  # Caddy web server
  services.caddy = {
    enable = true;

    # Serve WordPress on http://localhost:8000
    virtualHosts."http://localhost:8000" = {
      extraConfig = ''
        root * ${config.devenv.root}/wordpress

        # Pass PHP requests to PHP-FPM.
        php_fastcgi unix/${config.languages.php.fpm.pools.web.socket}

        # Serve static files directly
        file_server
      '';
    };
  };

  # Download WordPress and write wp-config.php once MariaDB is ready and seeded.
  # Runs automatically as part of `devenv up` via the caddy process dependency.
  tasks."wordpress:setup" = {
    description = "Download WordPress and create wp-config.php";
    after = [ "devenv:mysql:configure" ];
    cwd = config.devenv.root;
    exec = ''
      set -e

      mkdir -p wordpress
      cd wordpress

      if [ ! -f wp-includes/version.php ]; then
        echo "Downloading WordPress..."
        wp core download
      else
        echo "WordPress already downloaded."
      fi

      if [ ! -f wp-config.php ]; then
        echo "Creating wp-config.php..."
        wp config create \
          --dbname=wordpress \
          --dbuser=wordpress \
          --dbpass=wordpress \
          --dbhost=127.0.0.1
        echo ""
        echo "WordPress configured! Visit http://localhost:8000 to complete installation."
      else
        echo "wp-config.php already exists."
      fi
    '';
  };

  # Hold caddy until WordPress is on disk so the first request isn't a 404.
  processes.caddy.after = [ "wordpress:setup" ];

  # Show helpful instructions when entering the shell
  enterShell = ''
    echo ""
    echo "WordPress Development Environment"
    echo "=================================="
    echo ""
    echo "Run devenv up to start services and provision WordPress, then open:"
    echo "  http://localhost:8000"
    echo ""
    echo "Database credentials (for wp-config.php):"
    echo "  Host:     127.0.0.1"
    echo "  Database: wordpress"
    echo "  User:     wordpress"
    echo "  Password: wordpress"
    echo ""
  '';
}
