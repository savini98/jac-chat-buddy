import jaclang as jac

app = jac.jac_import("streamlit_app", base_path=".")[0]
print(app)

app.main()