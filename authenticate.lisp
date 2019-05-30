(in-package #:cl-keycloak)

(defclass client ()
  ((client-id
    :initarg :client-id
    :accessor client-id)
   (client-secret
    :initarg :client-secret
    :accessor client-secret)
   (server-url
    :initarg :server-url
    :accessor server-url)
   (key-realm
    :initarg :key-realm
    :accessor key-realm)
   (server-settings
    :initarg nil
    :accessor server-settings)))

(defun request-configuration (client)
  (setf (server-settings client)
        (yason:parse
          (flexi-streams:octets-to-string
            (drakma:http-request
              (format nil "~a/realms/~a/.well-known/openid-configuration"
                      (server-url client)
                      (key-realm client)))))))

(defun register-client (&key client-id client-secret server-url key-realm)
  (let ((client (make-instance 'client
                               :client-id client-id
                               :client-secret client-secret
                               :server-url server-url
                               :key-realm key-realm)))
    (request-configuration client)
    client))

(defun get-well-known (client well-known)
  (gethash well-known (server-settings client)))

(defmacro with-client (name args &body body)
  `(let ((,name (register-client ,@args)))
     ,@body))

(defun get-auth-redirect (client &key scope redirect)
  (format nil
    "~a?~a"
    (get-well-known client "authorization_endpoint")
    (url-encode `("client_id" . ,(client-id client))
                `("response_type" . "code")
                `("scope" . ,(or scope "openid"))
                `("redirect_uri" . ,redirect))))

(defun request-token (client code redirect)
  (yason:parse
    (flexi-streams:octets-to-string
      (drakma:http-request
        (get-well-known client "token_endpoint")
        :method :post
        :parameters `(("grant_type" . "authorization_code")
                      ("code" . ,code)
                      ("redirect_uri" . ,redirect)
                      ("client_id" . ,(client-id client))
                      ("client_secret" . ,(client-secret client)))))))

(defun get-user-info (client token)
  (yason:parse
    (flexi-streams:octets-to-string
      (drakma:http-request
        (get-well-known client "userinfo_endpoint")
        :method :get
        :additional-headers `(("Authorization" . ,(format nil "Bearer ~a" token)))))))
