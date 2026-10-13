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
    
    updateSelectInput(session,"x_var", selected = "bill_length_mm")
    
    updateSelectInput(session,"y_var", selected = "bill_depth_mm")
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
    
    req(
      nrow(filtered_data()) > 0
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
    
    click <- event_data(
      "plotly_click",
      source = "penguins"
    )
    
    req(click)
    
    penguins_data %>%
      filter(
        penguin_id == click$customdata[[1]]
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
    
    if (is.null(penguin) || nrow(penguin) != 1) {
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
  
  
  # ----------------------------------------------------------
  # Summary statistics
  # ----------------------------------------------------------
  
  # output$summary_table <- renderDT({
  #   
  #   summary_by_species(
  #     data = penguins_data,
  #     variable = input$measure
  #   ) %>%
  #     
  #     mutate(
  #       mean = round(mean, 1),
  #       median = round(median, 1),
  #       sd = round(sd, 1)
  #     ) %>%
  #     
  #     datatable(
  #       rownames = FALSE,
  #       
  #       options = list(
  #         dom = "t",
  #         pageLength = 5
  #       )
  #     )
  # })
  
  
  # ----------------------------------------------------------
  # Relationship data
  # ----------------------------------------------------------
  
  relationship_data <- reactive({
    
    penguins_data %>%
      filter(
        !is.na(.data[[input$x_relationship]]),
        !is.na(.data[[input$y_relationship]])
      ) %>%
      mutate(
        sex = ifelse(is.na(sex), "Unknown", sex)
      )
  })
  
  
  # ----------------------------------------------------------
  # Relationship plot
  # ----------------------------------------------------------
  
  output$relationship <- renderPlotly({
    
    penguin_relationship(
      data = relationship_data(),
      x = input$x_relationship,
      y = input$y_relationship,
      group = input$group_relationship
    )
  })
  
  
  # ----------------------------------------------------------
  # Correlation
  # ----------------------------------------------------------
  
  output$correlation <- renderText({
    
    correlation_value(
      data = relationship_data(),
      x = input$x_relationship,
      y = input$y_relationship
    ) %>%
      round(2)
  })
  
  
  # ----------------------------------------------------------
  # R squared
  # ----------------------------------------------------------
  
  output$r_squared <- renderText({
    
    regression_r_squared(
      data = relationship_data(),
      x = input$x_relationship,
      y = input$y_relationship
    ) %>%
      round(2)
  })
  
  
  # ----------------------------------------------------------
  # Number of observations
  # ----------------------------------------------------------
  
  output$n_observations <- renderText({
    
    nrow(relationship_data())
  })
  
  output$group_stats <- renderTable({
    
    data <- relationship_data()
    g <- input$group_relationship
    
    data %>%
      group_by(Group = .data[[g]]) %>%
      summarise(
        n = n(),
        Correlation = round(cor(.data[[input$x_relationship]],
                                .data[[input$y_relationship]]), 2),
        .groups = "drop"
      ) %>%
      mutate(`R²` = round(Correlation^2, 2))
  })
  
}