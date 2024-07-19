import jaclang as jac

(app,) = jac.jac_import("streamlit_app", base_path=".")
# if hasattr(app, 'main'):
#     app.main()
# else :
#     print('Error')

app.main()