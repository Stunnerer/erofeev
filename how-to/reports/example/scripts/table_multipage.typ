// continue-header-label - заголовок таблицы кроме 1-й страницы
// continue-footer-label - футор таблицы кроме 1-й и последней страницы
// last-footer-label - футор таблицы последней страницы (использую для примечаний)

#let table-multi-page(continue-header-label: [], continue-footer-label: [], last-footer-label: [], ..table-args) = context {
  let columns = table-args.named().at("columns", default: 1)
  let column-amount = if type(columns) == int {
    columns
  } else if type(columns) == array {
    columns.len()
  } else {
    1
  }

  // Check as show rule for appearance of a header or a footer in grid if value is specified
  let label-has-content = value => value.has("children") and value.children.len() > 0 or value.has("text")

  // Counter of tables so we can create a unique table-part-counter for each table
  let table-counter = counter("table")
  table-counter.step()

  // Counter for the amount of pages in the table
  let table-part-counter = counter("table-part" + str(table-counter.get().first()))

  show <table-footer>: footer => {
    table-part-counter.step()
    context if table-part-counter.get() != table-part-counter.final() and label-has-content(continue-footer-label) {
      footer
    }
    else if table-part-counter.get() == table-part-counter.final() and label-has-content(last-footer-label) {
      align(left + top)[#last-footer-label]
    }
    v(2em) // добавляет после футора пробел, что позволяет вставить нижний футор без наезда на колонтитул страницы
  }

  show <table-header>: header => {
    table-part-counter.step()
    context if (table-part-counter.get().first() != 1) and label-has-content(continue-header-label) {
      header
    }
  }

  grid(
    inset: 0mm,
    row-gutter: 2mm,
    fill: color.hsl(0deg, 0%, 0%, 0%), // Обратите внимание, что тело сетки растягивается сверху донизу, поэтому в нем может быть зазор для надписи нижнего колонтитула
    grid.header(grid.cell(align(left + bottom)[ #continue-header-label <table-header> ])),
    ..table-args,
    grid.footer(grid.cell(align(right + top)[#continue-footer-label <table-footer> ]))
  )
}
