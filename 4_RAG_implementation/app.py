import jaclang as jac

app = jac.jac_import("streamlit_app", base_path=".")
print(app[0])

app[0].main()