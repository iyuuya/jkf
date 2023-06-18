(use-modules ((guix licenses)
              #:prefix license:)
             (gnu packages ruby)
             (guix build-system ruby)
             (guix download)
             (guix git)
             (guix packages)
             (guix git-download))

(define-public ruby-guard-rubocop
  (package
    (name "ruby-guard-rubocop")
    (version "1.5.0")
    (source (origin
              (method url-fetch)
              (uri (rubygems-uri "guard-rubocop" version))
              (sha256
               (base32
                "0lb2fgfac97lvgwqvx2gbcimyvw2a0i76x6yabik3vmmvjbdfh9h"))))
    (build-system ruby-build-system)
    (arguments
     `(#:tests? #f)) ;TODO
    (propagated-inputs (list ruby-guard ruby-rubocop))
    (synopsis
     "Automatically checks Ruby code style with RuboCop when files are
modified")
    (description
     "@code{Guard::RuboCop} automatically checks Ruby code style with
RuboCop when files are modified.")
    (home-page "https://github.com/rubocop/guard-rubocop")
    (license license:expat)))

(define-public ruby-guard-compat
  (package
    (name "ruby-guard-compat")
    (version "1.2.1")
    (source (origin
              (method url-fetch)
              (uri (rubygems-uri "guard-compat" version))
              (sha256
               (base32
                "1zj6sr1k8w59mmi27rsii0v8xyy2rnsi09nqvwpgj1q10yq1mlis"))))
    (build-system ruby-build-system)
    (arguments
     `(#:test-target "spec"))
    (native-inputs (list ruby-rspec ruby-rubocop))
    (synopsis "Helps creating valid Guard plugins and testing them")
    (description "guard-compat helps creating valid Guard plugins and testing them.")
    (home-page "https://github.com/guard/guard-compat")
    (license license:expat)))

(define-public ruby-ruby-dep
  (package
    (name "ruby-ruby-dep")
    (version "1.5.0")
    (source (origin
             (method git-fetch)
             (uri (git-reference
                   (url "https://github.com/e2/ruby_dep")
                   (commit "4e79416a55dff4b3ff50e73c8fbd0455de1e68b7")))
             (file-name (git-file-name name version))
             (sha256
              (base32
               "0vv2bm4lghh5pl8zi0ihp6hpbp7xlk8d5h888nhxr725in0ypy9x"))))
    (build-system ruby-build-system)
    (arguments
     `(#:test-target "spec"
       #:tests? #f ;FIXME: needs gem_isolator, but cyclic dependencies
       ))
    (native-inputs (list ruby-rspec))
    (synopsis
     "Creates a version constraint of supported Rubies, suitable for a
gemspec file")
    (description
     "This package creates a version constraint of supported Rubies,
suitable for a gemspec file.")
    (home-page "https://github.com/e2/ruby_dep")
    (license license:expat)))

(define-public ruby-gem-isolator
  (package
    (name "ruby-gem-isolator")
    (version "0.2.3")
    (source (origin
             (method git-fetch)
             (uri (git-reference
                   (url "https://github.com/e2/gem_isolator")
                   (commit "1ec35362d946e682089a3983e7063593231d5188")))
             (file-name (git-file-name name version))
             (sha256
              (base32
               "1kkg7y2lw2jpdcdw33f2pvz9q14rlnx29l3a2qcwc5smivd03kww"))))
    (build-system ruby-build-system)
    (arguments
     `(#:test-target "spec"
       #:tests? #f ;FIXME: uninitialized constant Pathname
       ))
    (native-inputs (list ruby-rspec ruby-nenv ruby-rubocop))
    (propagated-inputs (list ruby-ruby-dep))
    (synopsis
     "Good for testing dependencies of a gem and/or different gem version
combinations")
    (description
     "gem_isolator is good for testing dependencies of a gem and/or
different gem version combinations.")
    (home-page "https://github.com/e2/gem_isolator")
    (license license:expat)))

(define-public ruby-guard-rspec
  (package
    (name "ruby-guard-rspec")
    (version "4.7.3")
    (source (origin
              (method url-fetch)
              (uri (rubygems-uri "guard-rspec" version))
              (sha256
               (base32
                "1jkm5xp90gm4c5s51pmf92i9hc10gslwwic6mvk72g0yplya0yx4"))))
    (build-system ruby-build-system)
    (arguments
     `(#:test-target "spec"
       #:tests? #f ;FIXME: uninitialized constant Bundler
       ))
    (native-inputs (list ruby-rubocop ruby-launchy ruby-gem-isolator bundler ruby))
    (propagated-inputs (list ruby-guard ruby-guard-compat ruby-rspec))
    (synopsis "Automatically run your specs (much like autotest)")
    (description
     "@code{Guard::RSpec} automatically run your specs (much like autotest).")
    (home-page "https://github.com/guard/guard-rspec")
    (license license:expat)))

(packages->manifest (list ruby-rake
                          ruby-yard
                          ruby-redcarpet
                          ruby-rubocop
                          ruby-guard-rubocop
                          ruby-rubocop-rake
                          ruby-rubocop-rspec
                          ruby-rspec
                          ruby-guard-rspec
                          ruby-simplecov
                          ruby))
