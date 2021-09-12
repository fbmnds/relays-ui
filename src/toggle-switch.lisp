
(in-package :relays-ui)


(rx:defm inner-span ()
  `(let ((class-name-inner-switch
           (if disabled@
               "toggle-switch-inner toggle-switch-disabled"
               "toggle-switch-inner")))
     (rx:react-element :span
                       (rx:{} class-name class-name-inner-switch
                              "data-yes" data-yes@
                              "data-no" data-no@
                              tab-index -1))))

(rx:defm switch-span ()
  `(let ((class-name-switch-span
           (if disabled@
               "toggle-switch-switch toggle-switch-disabled"
               "toggle-switch-switch")))
     (rx:react-element :span
                       (rx:{} class-name class-name-switch-span
                              tab-index -1))))

(rx:defm toggle-label ()
  `(if id@
       (rx:react-element :label
                         (rx:{} class-name "toggle-switch-label"
                                html-for id@
                                tab-index (if disabled@ -1 1))
                         (inner-span)
                         (switch-span))
       (rx:react-element :div nil)))

(rx:defm toggle-input ()
  `(rx:react-element :input
                     (rx:{} type "checkbox"
                            class-name "toggle-switch-checkbox"
                            name name@
                            id id@
                            checked checked@
                            disabled disabled@
                            on-change on-change@)))

(rx:defm toggle-switch-fn ()
  `(defun -toggle-switch (props)
     (rx:use-state "checked" 'false)
     (let* ((name@ (rx:@ props name))
            (id@ (rx:@ props id))
            (checked@ (rx:@ props checked))
            (disabled@ (rx:@ props disabled))
            (small@ (rx:@ props small))
            (option-labels@ (rx:@ props option-labels))
            (data-yes@ (or (rx:@ option-labels@ 0) "yes"))
            (data-no@ (or (rx:@ option-labels@ 1) "no"))
            (on-change@ (rx:@ props on-change)))
       (rx:react-element :div
                         (rx:{} class-name (if small@
                                               "toggle-switch small-switch"
                                               "toggle-switch"))
                         (toggle-input)
                         (toggle-label)))))

(rx:defm render-toggle-switch (tag props)
  `(rx:react-dom-render (rx:react-element -toggle-switch ,props)
                        (rx:doc-element ,tag)))

(rx:defm status-relay-fn ()
  `(rx:js (format nil "
    function statusRelay () { 
    var res;
    try {
        setDisabled1(true);
        setDisabled2(true);
        setDisabled3(true);
        setDisabled4(true);
        fetch('~a/?')
        .then(r => r.json())
        .then(state => {
              console.log(state);
              setRelay1(state.r1===1?true:false);
              setRelay2(state.r2===1?true:false);
              setRelay3(state.r3===1?true:false);
              setRelay4(state.r4===1?true:false);
              res = true;
        });
    } catch (e) { 
        res = null; 
    }
    setDisabled1(false);
    setDisabled2(false);
    setDisabled3(false);
    setDisabled4(false);
    return res;
}" ,*relay-url*)))

(rx:defm toggle-relay-fn ()
  `(rx:js (format nil "function toggleRelay (relay_nr) { 
    relay_nr===1?setDisabled1(true):
    relay_nr===2?setDisabled2(true):
    relay_nr===3?setDisabled3(true):
    relay_nr===4?setDisabled4(true):
    console.log('error relay_nr ' + relay_nr); 
    
(function () {
    try {
        fetch('~a/r' + relay_nr)
        .then(res => res.json())
        .then(state => {
              setRelay1(state.r1===1?true:false);
              setRelay2(state.r2===1?true:false);
              setRelay3(state.r3===1?true:false);
              setRelay4(state.r4===1?true:false);
              relay_nr===1?setDisabled1(false):
              relay_nr===2?setDisabled2(false):
              relay_nr===3?setDisabled3(false):
              relay_nr===4?setDisabled4(false):
              console.log('error relay_nr ' + relay_nr);
        });
    } catch (e) { 
        console.log('error toggleRelay' + e.toString()); 
        return null;
    }
})();
}" ,*relay-url*)))

(rx:defm relay-switch-fn (relay-nr)
  (let ((id (format nil "r~a" relay-nr))
        (fname (make-symbol (format nil "-relay-switch~a" relay-nr)))
        (text (format nil "Relay ~a" relay-nr)))
    `(defun ,fname (props)
       (let ((props2 (rx:{} id ,id
                           html-for ,id
                           text ,text
                           checked (rx:@ props checked)
                           disabled (rx:@ props disabled)
                           option-labels (ps:array " " " ")
                           on-change (ps:@ props on-change))))
         (rx:react-element :div (rx:{} class-name (if (rx:@ props2 disabled)
                                                      "relay relay-disabled"
                                                      "relay"))
                           (rx:react-element -toggle-switch props2)
                           (rx:react-element :div nil ,text))))))

(rx:defm render-relay-switch (relay-nr)
  (let ((fname (make-symbol (format nil "-relay-switch~a" relay-nr)))
        (tag (format nil "relay~a" relay-nr)))
    `(rx:react-dom-render (rx:react-element ,fname)
                          (rx:doc-element ,tag))))

(rx:defm relay-url-fn ()
  `(defun -relay-url (props)
     (rx:react-element -Alert props)))

(rx:defm render-relay-url (tag)
  `(rx:react-dom-render (rx:react-element -relay-url)
                        (rx:doc-element ,tag)))

(rx:defm relays-fn ()
  `(defun -relays (props)
     (rx:use-state "relay1" 'false)
     (rx:use-state "relay2" 'false)
     (rx:use-state "relay3" 'false)
     (rx:use-state "relay4" 'false)
     (rx:use-state "disabled1" 'false)
     (rx:use-state "disabled2" 'false)
     (rx:use-state "disabled3" 'false)
     (rx:use-state "disabled4" 'false)
     (toggle-relay-fn)
     (status-relay-fn)
     (rx:js "(function () { statusRelay(); }).bind(this); 
             React.useEffect(() => { statusRelay(); }, []);")
     (rx:react-element
      :div nil
      (rx:react-element -relay-switch1
                        (rx:{} id "r1"
                               checked relay1
                               disabled disabled1
                               on-change (rx:tlambda ()
                                                     (toggle-relay 1))))
      (rx:react-element -relay-switch2
                        (rx:{} id "r2"
                               checked relay2
                               disabled disabled2
                               on-change (rx:tlambda () (toggle-relay 2))))
      (rx:react-element -relay-switch3
                        (rx:{} id "r3"
                               checked relay3
                               disabled disabled3
                               on-change (rx:tlambda () (toggle-relay 3))))
      (rx:react-element -relay-switch4
                        (rx:{} id "r4"
                               checked relay4
                               disabled disabled4
                               on-change (rx:tlambda () (toggle-relay 4))))
      (rx:react-element -relay-url (rx:{} variant
                                          (if (or disabled1
                                                  disabled2
                                                  disabled3
                                                  disabled4)
                                              "info"
                                              "light")
                                          text ,*relay-url*)))))

(rx:defm render-relays ()
  `(progn
     (rx:react-dom-render (rx:react-Element -Relays nil)
                          (rx:doc-element "relays"))))



