
(in-package :relays-ui)


(rx:defm relay-tab (event-key title element)
  `(rx:react-bootstrap-tab* -tab
                            (rx:{} event-key ,event-key title ,title)
                            ,element))

(rx:defm lines-tab ()
  `(rx:react-bootstrap-tab* -tab
                            (rx:{} event-key "lines" title "Lines")
                            (rx:react-element -lines nil)
                            (rx:react-element -range
                                              (rx:{} min 0
                                                     max 100
                                                     initial 50
                                                     on-change
                                                     (lambda (v)
                                                       ((ps:@ console log) v))))))

(rx:defm tabs (active-key id class-name tag)
  `(progn
     (rx:react-dom-render
      (rx:react-bootstrap-tab* -tabs
                               (rx:{} default-active-key ,active-key
                                      id ,id
                                      class-name ,class-name)
                               (relay-tab "-relays-16-e5-f0" "ESP-16E5F0"
                                          (rx:react-element -relays-16-e5-f0 nil))
                               (relay-tab "-relays-4-d-c-c5-f" "ESP-4DCC5F"
                                          (rx:react-element -relays-4-d-c-c5-f nil))
                               (lines-tab))
      (rx:doc-element ,tag))))



