import marimo

__generated_with = "0.18.4"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Sample Marimo Notebook
    """)
    return


@app.cell
def _():
    from research_project_template.config import RAW_DATA_DIR

    RAW_DATA_DIR
    return


if __name__ == "__main__":
    app.run()
