
ui <- page_navbar(
  
  title = tags$span("ShinyPenguins", style = "font-weight: 700; font-size: 1.4rem;"),
  
  fillable = FALSE,
  
  theme = bs_theme(
    version = 5,
    bootswatch = "minty",
    primary = "#2C5F6F",
    font_scale = 0.95
  ),
  
  
  # ==============  tab 1 ==============
  
  nav_panel(
    title = "Explore Penguins",
    
    # ---------------------- compact header ----------------------
    div(
      class = "px-3 pt-2 pb-1",
      layout_columns(
        col_widths = c(8, 4),
        fill = FALSE,
        
        div(
          h2("Explore the Penguins", class = "h2 fw-bold mb-1"),
          p(
            "Explore relationships between penguin species, ",
            "islands and physical measurements from the ",
            "Palmer Archipelago.",
            class = "lead mb-1"
          ),
          p(
            "Use the filters to explore the data, ",
            "then click a penguin to inspect an individual.",
            class = "mb-0"
          )
        ),
        
        div(
          class = "text-center",
          div(
            class = "d-flex justify-content-center align-items-center gap-3",
            tags$img(
              src = "lter_penguins.png",
              alt = "Palmer Penguins illustration",
              style = "max-height: 100px; max-width: 48%;"
            )
          ),
          tags$p(
            em("Artwork by @allison_horst"),
            class = "small text-muted mb-0 mt-1"
          )
        )
      )
    ),
    
    # ------------------------ sidebar ---------------------------
    layout_sidebar(
      sidebar = sidebar(
        h5("Filters"),
        selectInput("species", "Species",
                    choices = c("All species" = "All", "Adelie" = "Adelie",
                                "Chinstrap" = "Chinstrap", "Gentoo" = "Gentoo"),
                    selected = "All"
        ),
        selectInput("island", "Island",
                    choices = c("All islands" = "All", "Biscoe" = "Biscoe",
                                "Dream" = "Dream", "Torgersen" = "Torgersen"),
                    selected = "All"
        ),
        selectInput("sex", "Sex",
                    choices = c("All" = "All", "Female" = "female", "Male" = "male"),
                    selected = "All"
        ),
        hr(),
        h5("Plot variables"),
        selectInput("x_var", "X-axis",
                    choices = c("Bill length" = "bill_length_mm",
                                "Bill depth" = "bill_depth_mm",
                                "Flipper length" = "flipper_length_mm",
                                "Body mass" = "body_mass_g"),
                    selected = "bill_length_mm"
        ),
        selectInput("y_var", "Y-axis",
                    choices = c("Bill length" = "bill_length_mm",
                                "Bill depth" = "bill_depth_mm",
                                "Flipper length" = "flipper_length_mm",
                                "Body mass" = "body_mass_g"),
                    selected = "bill_depth_mm"
        ),
        hr(),
        actionButton("reset", "Reset filters",
                     class = "btn-outline-secondary w-100")
      ),
      
      # ---------------------- main content ----------------------
      # value boxes (full width)
      layout_columns(
        col_widths = c(4, 4, 4),
        fill = FALSE,
        value_box(title = "Penguins", value = textOutput("n_penguins"),
                  showcase = bsicons::bs_icon("people"), height = "90px"),
        value_box(title = "Species", value = textOutput("n_species"),
                  showcase = bsicons::bs_icon("tags"), height = "90px"),
        value_box(title = "Islands", value = textOutput("n_islands"),
                  showcase = bsicons::bs_icon("geo"), height = "90px")
      ),
      
      # plot (wide) + selected penguin (narrow) side by side
      layout_columns(
        col_widths = c(8, 4),
        fill = FALSE,
        card(
          card_header(h5("Penguin morphology", class = "mb-0")),
          card_body(
            plotly::plotlyOutput("scatter", height = "550px")
          )
        ),
        card(
          card_header(h5("Selected penguin", class = "mb-0")),
          card_body(
            uiOutput("selected_penguin"),
            hr(),
            tags$img(
              src = "culmen_depth.png",
              alt = "Penguin bill dimensions illustration",
              style = "max-width: 100%; max-height: 150px;
                       display: block; margin: auto;"
            ),
            tags$p(
              em("Bill length and depth are measured on the culmen."),
              class = "small text-muted text-center mb-0 mt-2"
            )
          )
        )
      )
    )
  ),
  
  
  # ==========================================================
  # TAB 2 — COMPARE & ANALYSE
  # ==========================================================
  
  nav_panel(
    
    title = "Compare & Analyse",
    
    # --------------------------------------------------------
    # Introduction
    # --------------------------------------------------------
    
    div(
      class = "px-3 pt-2 pb-1",
      h2("Compare & Analyse", class = "h2 fw-bold mb-1"),
      p(
        "Compare measurements across species and investigate ",
        "relationships between physical characteristics.",
        class = "lead mb-1"
      )
    ),
    
    
    # ========================================================
    # DISTRIBUTION
    # ========================================================
    
    card(
      card_header(h5("Measurement by species", class = "mb-0")),
      card_body(
        layout_columns(
          col_widths = c(8, 4),
          fill = FALSE,
          
          div(
            selectInput("measure", NULL,
                        choices = c("Body mass" = "body_mass_g",
                                    "Flipper length" = "flipper_length_mm",
                                    "Bill length" = "bill_length_mm",
                                    "Bill depth" = "bill_depth_mm"),
                        selected = "body_mass_g",
                        width = "220px"),
            plotly::plotlyOutput("distribution", height = "350px")
          ),
          
          div(
            class = "d-flex flex-column justify-content-center h-100",
            h5("Summary"),
            div(style = "font-size: 1.1rem;", tableOutput("summary_table"))
          )
        )
      )
    ),
    
    
    # ========================================================
    # RELATIONSHIP ANALYSIS
    # ========================================================
    
    card(
      card_header(h5("Explore a relationship", class = "mb-0")),
      card_body(
        layout_columns(
          col_widths = c(8, 4),
          fill = FALSE,
          
          div(
            layout_columns(
              col_widths = c(6, 6),
              fill = FALSE,
              selectInput("x_relationship", "X variable",
                          choices = c("Flipper length" = "flipper_length_mm",
                                      "Bill length" = "bill_length_mm",
                                      "Bill depth" = "bill_depth_mm",
                                      "Body mass" = "body_mass_g"),
                          selected = "flipper_length_mm"),
              selectInput("y_relationship", "Y variable",
                          choices = c("Body mass" = "body_mass_g",
                                      "Flipper length" = "flipper_length_mm",
                                      "Bill length" = "bill_length_mm",
                                      "Bill depth" = "bill_depth_mm"),
                          selected = "body_mass_g")
            ),
            plotly::plotlyOutput("relationship", height = "380px")
          ),
          
          div(
            class = "d-flex flex-column justify-content-center h-100",
            h5("By species"),
            div(style = "font-size: 1.1rem;", tableOutput("group_stats"))
          )
        )
      )
    )
  ),
  
  
  # ==========================================================
  # FOOTER
  # ==========================================================
  
  footer = div(
    class = "text-center text-muted p-4",
    
    "Built with R, Shiny, bslib & Plotly · ",
    "Data: palmerpenguins"
  )
)
