(in-package #:cl-keycloak)

(defun char-encode-p (char)
  (not (digit-char-p char 36)))

(defun char-encode (char)
  (format nil "%~2,'0X"
          (char-code char)))

(defun string-encode (string)
  (with-output-to-string (*standard-output* nil)
    (loop :for x :across string
          :if (char-encode-p x)
          :do (princ (char-encode x))
          :else
          :do (princ x))))

(defun url-encode (&rest args)
  (format nil "~{~a~^&~}"
          (loop :for x :in args
                :collect (format nil "~a=~a" (car x) (string-encode (cdr x))))))
