server <- function(input, output, session) {

  filtered_data <- reactive({
    
    data <- penguins_data
    
    # Species filter
    if (input$species != "All") {
      data <- data %>% filter(species == input$species)
    }
    
    
    # Island filter
    if (input$island != "All") {
      data <- data %>% filter(island == input$island)
    }
    
    
    # Sex filter
    if (input$sex != "All") {
      data <- data %>% filter(sex == input$sex)
    }
    
    data
  })
  
  
  # ----------------------------------------------------------
  # Reset filters
  # ----------------------------------------------------------
  
  observeEvent(input$reset, {
    
    updateSelectInput(session, "species", selected = "All")
    updateSelectInput(session, "island", selected = "All")
    updateSelectInput(session, "sex", selected = "All")

  })
  
  
  # ----------------------------------------------------------
  # Number of penguins
  # ----------------------------------------------------------
  
  output$n_penguins <- renderText({
    
    nrow(
      filtered_data()
    )
  })
  
  
  # ----------------------------------------------------------
  # KPI: number of species
  # ----------------------------------------------------------
  
  output$n_species <- renderText({
    
    n_distinct(
      filtered_data()$species
    )
  })
  
  
  # ----------------------------------------------------------
  # KPI: number of islands
  # ----------------------------------------------------------
  
  output$n_islands <- renderText({
    
    n_distinct(
      filtered_data()$island
    )
  })
  
  
  # ----------------------------------------------------------
  # Main scatter plot
  # ----------------------------------------------------------
  
  output$scatter <- renderPlotly({
    
    validate(
      need(
        nrow(filtered_data()) > 0,
        "No penguins match the selected filters. Please adjust your filters."
      )
    )
    
    penguin_scatter(
      data = filtered_data(),
      x = input$x_var,
      y = input$y_var
    )
  })

  
  # ----------------------------------------------------------
  # Selected penguin
  # ----------------------------------------------------------
  
  selected_penguin <- reactive({
    
    click <- event_data("plotly_click", source = "penguins")
    
    if (is.null(click)) return(NULL)
    
    penguins_data %>%
      filter(penguin_id == click$customdata[[1]])
  })
  
  
  output$selected_penguin <- renderUI({
    
    penguin <- selected_penguin()
    
    if (
      is.null(penguin) || nrow(penguin) != 1 ||
      !penguin$penguin_id %in% filtered_data()$penguin_id
    ) {
      return(
        p(
          em("Click a penguin in the plot to see its details."),
          class = "text-muted"
        )
      )
    }
    
    species_name <- as.character(penguin$species)
    
    div(
      h4(
        paste("🐧", species_name),
        style = paste0("color: ", species_colors[[species_name]], ";")
      ),
      
      p(strong("Island: "), penguin$island),
      p(strong("Sex: "), format_sex(penguin$sex)),
      p(strong("Study year: "), penguin$year),
      
      hr(),
      
      layout_columns(
        col_widths = c(6, 6),
        fill = FALSE,
        
        div(
          strong("Body mass"), br(),
          paste0(format_value(penguin$body_mass_g), " g")
        ),
        div(
          strong("Flipper length"), br(),
          paste0(format_value(penguin$flipper_length_mm), " mm")
        ),
        div(
          strong("Bill length"), br(),
          paste0(format_value(penguin$bill_length_mm), " mm")
        ),
        div(
          strong("Bill depth"), br(),
          paste0(format_value(penguin$bill_depth_mm), " mm")
        )
      )
    )
  })
  
  
  # ==========================================================
  # COMPARE & ANALYSE TAB
  # ==========================================================
  
  
  # ----------------------------------------------------------
  # Distribution plot
  # ----------------------------------------------------------
  
  output$distribution <- renderPlotly({
    
    penguin_distribution(
      data = penguins_data,
      variable = input$measure
    )
  })
  
  output$summary_table <- renderTable({
    penguins_data %>%
      group_by(Species = as.character(species)) %>%
      summarise(
        n      = sum(!is.na(.data[[input$measure]])),
        Mean   = round(mean(.data[[input$measure]], na.rm = TRUE), 1),
        Median = round(median(.data[[input$measure]], na.rm = TRUE), 1),
        SD     = round(sd(.data[[input$measure]], na.rm = TRUE), 1),
        .groups = "drop"
      )
  }, width = "100%", spacing = "l")
  
  # ----------------------------------------------------------
  # Relationship data
  # ----------------------------------------------------------
  
  relationship_data <- reactive({
    
    penguins_data %>%
      filter(
        !is.na(.data[[input$x_relationship]]),
        !is.na(.data[[input$y_relationship]])
      ) %>% 
      mutate(sex = format_sex(sex))
  })
  
  
  # ----------------------------------------------------------
  # Relationship plot
  # ----------------------------------------------------------
  
  output$relationship <- renderPlotly({
    
    validate(
      need(
        input$x_relationship != input$y_relationship,
        "Please select two different variables for X and Y."
      )
    )
    
    penguin_relationship(
      data = relationship_data(),
      x = input$x_relationship,
      y = input$y_relationship,
      group = "species"
    )
  })
  
  
  output$group_stats <- renderTable({
    
    validate(
      need(
        input$x_relationship != input$y_relationship, ""
        )
      )
    
    x <- input$x_relationship
    y <- input$y_relationship
    data <- relationship_data()
    
    by_species <- data %>%
      group_by(Species = as.character(species)) %>%
      summarise(
        n = n(),
        Correlation = cor(.data[[x]], .data[[y]]),
        .groups = "drop"
      )
    
    overall <- tibble(
      Species = "All penguins",
      n = nrow(data),
      Correlation = cor(data[[x]], data[[y]])
    )
    
    bind_rows(by_species, overall)
  }, width = "100%", spacing = "l", digits = 2)
  
}
