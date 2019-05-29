;;;; cl-keycloak.asd

(asdf:defsystem #:cl-keycloak
  :description "Describe cl-keycloak here"
  :author "Your Name <your.name@example.com>"
  :license  "GPLv3"
  :version "0.0.1"
  :serial t
  :depends-on (#:drakma #:flexi-streams #:yason)
  :components ((:file "package")
               (:file "authenticate")
               (:file "url-encode")))
