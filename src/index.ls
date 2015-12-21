require! {
  react: {create-element}
  redux: {create-store, apply-middleware}
  \react-redux : {Provider}
  \react-dom : {render}
  \redux-thunk : thunk-middleware
  \./components/Rblg.ls
  \./reducers.ls
}

render do
  create-element do
    Provider
    store: apply-middleware(thunk-middleware)(create-store)(reducers)
    create-element Rblg
  document.get-element-by-id \Rblg
