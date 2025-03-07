class Phpstan < Formula
  desc "PHP Static Analysis Tool"
  homepage "https://github.com/phpstan/phpstan"
  url "https://github.com/phpstan/phpstan/releases/download/1.9.9/phpstan.phar"
  sha256 "5858a6ee2c71eb94a2dece72542d9e11aaae5b141849b98eeecf6dc5e1fa403e"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "5dbec58cece518ce2e48bd58629c10db20636f5bf391e2f190e704de4356f1da"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5dbec58cece518ce2e48bd58629c10db20636f5bf391e2f190e704de4356f1da"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "5dbec58cece518ce2e48bd58629c10db20636f5bf391e2f190e704de4356f1da"
    sha256 cellar: :any_skip_relocation, ventura:        "bd7321e78aaf6cdecd445688866b9db0a3792c41ea4e70896933d8d16d59b2cb"
    sha256 cellar: :any_skip_relocation, monterey:       "bd7321e78aaf6cdecd445688866b9db0a3792c41ea4e70896933d8d16d59b2cb"
    sha256 cellar: :any_skip_relocation, big_sur:        "bd7321e78aaf6cdecd445688866b9db0a3792c41ea4e70896933d8d16d59b2cb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "5dbec58cece518ce2e48bd58629c10db20636f5bf391e2f190e704de4356f1da"
  end

  depends_on "php" => :test

  # Keg-relocation breaks the formula when it replaces `/usr/local` with a non-default prefix
  on_macos do
    on_intel do
      pour_bottle? only_if: :default_prefix
    end
  end

  def install
    bin.install "phpstan.phar" => "phpstan"
  end

  test do
    (testpath/"src/autoload.php").write <<~EOS
      <?php
      spl_autoload_register(
          function($class) {
              static $classes = null;
              if ($classes === null) {
                  $classes = array(
                      'email' => '/Email.php'
                  );
              }
              $cn = strtolower($class);
              if (isset($classes[$cn])) {
                  require __DIR__ . $classes[$cn];
              }
          },
          true,
          false
      );
    EOS

    (testpath/"src/Email.php").write <<~EOS
      <?php
        declare(strict_types=1);

        final class Email
        {
            private string $email;

            private function __construct(string $email)
            {
                $this->ensureIsValidEmail($email);

                $this->email = $email;
            }

            public static function fromString(string $email): self
            {
                return new self($email);
            }

            public function __toString(): string
            {
                return $this->email;
            }

            private function ensureIsValidEmail(string $email): void
            {
                if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                    throw new InvalidArgumentException(
                        sprintf(
                            '"%s" is not a valid email address',
                            $email
                        )
                    );
                }
            }
        }
    EOS
    assert_match(/^\n \[OK\] No errors/,
      shell_output("#{bin}/phpstan analyse --level max --autoload-file src/autoload.php src/Email.php"))
  end
end
