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

AJAX_ALWAYS_SOURCE_APPEND = {
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
                                               id: "if01", element: "messageTable",
                                               func: "appendElements", type: "element",
                                               params: [
                                                        {
                                                         tag: "tr",
                                                         children: [
                                                                    {
                                                                     tag: "td"
                                                                    },
                                                                    {
                                                                     tag: "td",
                                                                     value: { name: "message", type: "string" }
                                                                    }
                                                                   ]
                                                        }
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

AJAX_CONDITIONAL_SOURCE = {
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
                                      type: "conditional",
                                      condition: {
                                                  operand: "eq",
                                                  left: {
                                                         type: "param",
                                                         value: {
                                                                 name: "message",
                                                                 type: "string"
                                                                }
                                                        },
                                                  right: {
                                                         type: "literal",
                                                         value: {
                                                                 value: "hoge",
                                                                 type: "string"
                                                                }
                                                         }
                                                 },
                                      then: {
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
                                            },
                                      else: {
                                             interfaces: [],
                                             databases: []
                                            }
                                     }
                            }
                           ]
                          }

REALTIME_ALWAYS_SOURCE = {
                          events:
                          [
                           {
                            id: "event01", target: "submitBtn", type: "onClick", realtime: true,
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

REALTIME_CONDITIONAL_SOURCE = {
                           events:
                           [
                            {
                             id: "event01", target: "submitBtn", type: "onClick", realtime: true,
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
                                      type: "conditional",
                                      condition: {
                                                  operand: "eq",
                                                  left: {
                                                         type: "param",
                                                         value: {
                                                                 name: "message",
                                                                 type: "string"
                                                                }
                                                        },
                                                  right: {
                                                         type: "literal",
                                                         value: {
                                                                 value: "hoge",
                                                                 type: "string"
                                                                }
                                                         }
                                                 },
                                      then: {
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
                                            },
                                      else: {
                                             interfaces: [],
                                             databases: []
                                            }
                                     }
                            }
                           ]
                          }
