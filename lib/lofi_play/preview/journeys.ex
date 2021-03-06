defmodule LofiPlay.Preview.Journeys do
  use Phoenix.HTML
  import LofiPlay.Preview.Utilities

  defp process_element(%Lofi.Element{children: [], tags_path: ["screen" | _tags_path_rest]} = %{tags_hash: tags_hash}) do
    {:screen, tags_hash}
  end

  defp process_element(%Lofi.Element{children: [], tags_path: ["message" | _tags_path_rest]} = %{tags_path: tags_hash}) do
    {:message, tags_hash}
  end

  defp process_element(%Lofi.Element{children: children, tags_path: ["story" | _tags_path_rest]}) do
    {:story, children}
  end

  defp process_element(%Lofi.Element{children: children, tags_path: ["promotion" | _tags_path_rest]} = element) do
    {:promotion, element}
  end

  defp process_element(%Lofi.Element{children: children, texts: texts}) do
    {:text, texts}
  end

  defp process_section({lines, index}, preview) do
    html_lines = lines
    |> Enum.map(&process_element/1)
    |> Enum.map(preview)
    
    content_tag(:div, [
      content_tag(:div, html_lines, class: "mb-3")
    ])
  end

  defp process_carousel_section({lines, index}, preview) do
    html_lines = lines
    |> Enum.map(&process_element/1)
    |> Enum.map(preview)

    class = flatten_classes [
      {"carousel-item", true},
      {"active", index == 1}
    ]
    
    content_tag(:div, [
      content_tag(:div, html_lines, class: "mb-3")
    ], class: class)
  end

  defp carousel_controls do
    [
      content_tag(:a, [
        content_tag(:span, "", class: "carousel-control-prev-icon", aria: [hidden: "true"]),
        content_tag(:span, "Previous", class: "sr-only")
      ], class: "carousel-control-prev", role: "button", data: [slide: "prev"]),
      content_tag(:a, [
        content_tag(:span, "", class: "carousel-control-next-icon", aria: [hidden: "true"]),
        content_tag(:span, "Next", class: "sr-only")
      ], class: "carousel-control-next", role: "button", data: [slide: "next"])
    ]
  end

  defp carousel(items) do
    content_tag(:div, [
      content_tag(:div, items, class: "carousel-inner"),
      carousel_controls
    ] |> List.flatten, class: "carousel slide")
  end

  defp process_carousel_sections(sections, preview) do
    sections
    |> Enum.with_index
    |> Enum.map(&process_carousel_section(&1, preview))
    |> list
  end

  defp list(items) do
    content_tag(:div, items)
  end

  defp process_sections(sections, preview) do
    sections
    |> Enum.with_index
    |> Enum.map(&process_section(&1, preview))
    |> list
  end

  def preview_content(content, preview) do
    Lofi.Parse.parse_sections(content)
    |> process_sections(preview)
  end
end