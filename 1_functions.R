# ===================== data =====================

penguins_data <- palmerpenguins::penguins %>%
  mutate(sex = as.character(sex),
         penguin_id = row_number())

# Colours taken from the Allison Horst artwork
species_colors <- c(
  "Adelie"    = "#FF8C00",   # orange
  "Chinstrap" = "#C65ACF",   # purple
  "Gentoo"    = "#067476"    # teal
)

format_sex <- function(x) {
  ifelse(is.na(x), "Unknown", tools::toTitleCase(x))
}


# ============= labels for variables =============

variable_label <- function(x) {
  
  labels <- c(
    bill_length_mm = "Bill length (mm)",
    bill_depth_mm = "Bill depth (mm)",
    flipper_length_mm = "Flipper length (mm)",
    body_mass_g = "Body mass (g)"
  )
  
  # removes the names from the vector
  unname(labels[x])
}


# ============ format numbers for UI ============

format_value <- function(x, digits = 1) {
  
  if (is.na(x)) {
    return("—")
  }
  
  formatC(x, format = "f", digits = digits, big.mark = ",")
}


# ======== scatter plot for explore tab =========

penguin_scatter <- function(data, x, y) {

  data <- data %>%
    mutate(
      sex_label = factor(
        format_sex(sex),
        levels = c("Female", "Male", "Unknown")
      )
    )

  plot_ly(
    data = data,

    x = ~.data[[x]],
    y = ~.data[[y]],

    type = "scatter",
    mode = "markers",

    source = "penguins",

    color = ~species,
    colors = species_colors,

    symbol = ~sex_label,
    symbols = c(
      "Female"  = "circle",
      "Male"    = "triangle-up",
      "Unknown" = "circle-open"
    ),

    marker = list(size = 8, line = list(width = 1.5)),

    customdata = ~penguin_id,

    text = ~paste0(
      "<b>", species, "</b>",
      "<br>Island: ", island,
      "<br>Sex: ", format_sex(sex),
      "<br>Body mass: ",
      ifelse(is.na(body_mass_g), "Unknown", paste0(body_mass_g, " g")),
      "<br>Flipper length: ",
      ifelse(is.na(flipper_length_mm), "Unknown", paste0(flipper_length_mm, " mm"))
    ),

    hoverinfo = "text"
  ) %>%
    layout(
      xaxis = list(title = variable_label(x)),
      yaxis = list(title = variable_label(y), automargin = TRUE),
      legend = list(
        orientation = "h",
        xref = "container", x = 0.5, xanchor = "center",
        yref = "container", y = 0,   yanchor = "bottom"
      ),
      margin = list(b = 120)
    ) %>%
    config(
      toImageButtonOptions = list(
        format   = "png",
        filename = "penguin_scatter",
        scale    = 3
      )
    )
}


# ========== box plot for compare tab ===========

penguin_distribution <- function(data, variable) {

  data <- data %>%
    filter(!is.na(.data[[variable]]))

  plot_ly(
    data = data,

    x = ~species,
    y = ~.data[[variable]],

    color = ~species,
    colors = species_colors,

    type = "box",

    boxpoints = "all",
    jitter = 0.25,
    pointpos = 0
  ) %>%
    layout(
      xaxis = list(title = ""),
      yaxis = list(title = variable_label(variable)),
      showlegend = FALSE
    ) %>%
    config(
      toImageButtonOptions = list(
        format   = "png",
        filename = "penguin_boxplot",
        scale    = 3
      )
    )
}


# ============== relationship plot ==============

penguin_relationship <- function(data, x, y, group) {

  plot_ly(
    data = data,
    x = ~.data[[x]],
    y = ~.data[[y]],
    color = ~.data[[group]],
    colors = if (group == "species") species_colors else NULL,
    type = "scatter",
    mode = "markers",
    text = ~paste0(
      "<b>", species, "</b>",
      "<br>Island: ", island,
      "<br>Sex: ", format_sex(sex)
    ),
    hoverinfo = "text+x+y"
  ) %>%
    layout(
      xaxis = list(title = variable_label(x)),
      yaxis = list(title = variable_label(y), automargin = TRUE),
      legend = list(orientation = "h", x = 0, y = 1.12),
      margin = list(t = 60)
    ) %>%
    config(
      toImageButtonOptions = list(
        format   = "png",
        filename = "penguin_relationship",
        scale    = 3
      )
    )
}