import:py streamlit as st;

can page_build {
    st.set_page_config(
                    page_title="JacCare Health Assistant",
                    page_icon=":robot:",
                    layout="wide");
    # (left_co, cent_co,last_co) = st.columns(3);
    # with cent_co {
    # st.image(Image.open("images/JacCare LOGO.png"));
    # st.title("${\Large JacCare}$");
    # }

    st.image(Image.open("images/JacCare LOGO.png"));
    st.title("Jac${Care}$");
}