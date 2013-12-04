AJAX_ALWAYS_SOURCE = {
                       events:
                       [
                        {
                         id: "event01", target: "submitBtn", type: "onClick", realtime: false,
                         params: [
                                  {
                                   name: "message", type: "string",
                                   value: {
                                           element: "messageTextBox",
                                           func: "getValue", type: "element"
                                          }
                                  }
                                 ],
                         action: {
                                  type: "always",
                                  interfaces: [
                                               {
                                                id: "if01", element: "messageLabel",
                                                func: "setValue", type: "element",
                                                params: [
                                                         { name: "message", type: "string" }
                                                        ]

                                               }
                                              ],
                                  databases: [
                                              {
                                               id: "db01", database: "messages", func: "create",
                                               params: [
                                                        { name: "message", type: "string" }
                                                       ]
                                              }
                                             ]
                                 }
                        }
                       ]
                      }
