import jaclang as jac

app = jac.jac_import("streamlit_app", base_path=".")

app[0].main()