
ui <- page_navbar(
  
  title = "Palmer Penguins App",
  
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
          h1("Explore the Penguins", class = "h2 fw-bold mb-1"),
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
                  showcase = bsicons::bs_icon("people"), height = "110px"),
        value_box(title = "Species", value = textOutput("n_species"),
                  showcase = bsicons::bs_icon("gender-ambiguous"), height = "110px"),
        value_box(title = "Islands", value = textOutput("n_islands"),
                  showcase = bsicons::bs_icon("geo"), height = "110px")
      ),
      
      # plot (wide) + selected penguin (narrow) side by side
      layout_columns(
        col_widths = c(8, 4),
        fill = FALSE,
        card(
          card_header("Penguin morphology"),
          card_body(
            plotly::plotlyOutput("scatter", height = "450px")
          )
        ),
        card(
          card_header("Selected penguin"),
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
      class = "p-4",
      
      h1(
        "Compare & Analyse",
        class = "fw-bold"
      ),
      
      p(
        "Compare measurements across species and investigate ",
        "relationships between physical characteristics.",
        class = "lead"
      )
    ),
    
    
    # ========================================================
    # DISTRIBUTION
    # ========================================================
    
    card(
      
      card_header(
        
        layout_columns(
          
          div(
            h5(
              "Measurement by species",
              class = "mb-0"
            )
          ),
          
          selectInput(
            "measure",
            NULL,
            
            choices = c(
              "Body mass" = "body_mass_g",
              "Flipper length" = "flipper_length_mm",
              "Bill length" = "bill_length_mm",
              "Bill depth" = "bill_depth_mm"
            ),
            
            selected = "body_mass_g",
            width = "180px"
          ),
          
          col_widths = c(8, 4)
        )
      ),
      
      card_body(
        
        plotly::plotlyOutput(
          "distribution",
          height = "450px"
        )
      )
    ),
    
    
    # # ========================================================
    # # SUMMARY STATISTICS
    # # ========================================================
    # 
    # card(
    #   
    #   card_header(
    #     "Summary statistics"
    #   ),
    #   
    #   card_body(
    #     
    #     DT::DTOutput(
    #       "summary_table"
    #     )
    #   )
    # ),
    
    
    # ========================================================
    # RELATIONSHIP ANALYSIS
    # ========================================================
    
    card(
      
      card_header(
        "Explore a relationship"
      ),
      
      card_body(
        
        layout_columns(
          
          selectInput(
            "x_relationship",
            "X variable",
            
            choices = c(
              "Flipper length" = "flipper_length_mm",
              "Bill length" = "bill_length_mm",
              "Bill depth" = "bill_depth_mm",
              "Body mass" = "body_mass_g"
            ),
            
            selected = "flipper_length_mm"
          ),
          
          selectInput(
            "y_relationship",
            "Y variable",
            
            choices = c(
              "Body mass" = "body_mass_g",
              "Flipper length" = "flipper_length_mm",
              "Bill length" = "bill_length_mm",
              "Bill depth" = "bill_depth_mm"
            ),
            
            selected = "body_mass_g"
          ),
          
          selectInput(
            "group_relationship",
            "Group by",
            
            choices = c(
              "Species" = "species",
              "Sex" = "sex",
              "Island" = "island"
            ),
            
            selected = "species"
          ),
          
          col_widths = c(4, 4, 4)
        ),
        
        
        # ------------------------------------------------------
        # Relationship plot
        # ------------------------------------------------------
        
        plotly::plotlyOutput(
          "relationship",
          height = "500px"
        ),
        
        
        # ------------------------------------------------------
        # Statistics
        # ------------------------------------------------------
        
        layout_columns(
          
          value_box(title = "Correlation (all penguins)", value = textOutput("correlation")),
          value_box(title = "R² (all penguins)",          value = textOutput("r_squared")),
          value_box(title = "Observations",               value = textOutput("n_observations")
          ),
          
          col_widths = c(4, 4, 4)
        ),
        
        h6("By group", class = "mt-3"),
        tableOutput("group_stats")
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
