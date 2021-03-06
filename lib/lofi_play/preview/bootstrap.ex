defmodule LofiPlay.Preview.Bootstrap do
  import LofiPlay.Preview.Utilities
  import LofiPlay.Preview.Lofi
  import LofiPlay.Preview.Components
  alias Phoenix.HTML
  alias Phoenix.HTML.Tag
  alias LofiPlay.Preview.Primitives
  alias LofiPlay.Preview.Promotion
  alias LofiPlay.Content.Component

  @doc """
  Flattens a list of class name / boolean tuples into a single class string

      iex> flatten_classes [{"btn", true}, {"active", false}, {"btn-primary", true}]
      "btn btn-primary"
  """
  # defp flatten_classes(classes) do
  #   classes
  #   |> Enum.filter(&(Kernel.elem(&1, 1))) # Keep where .1 is true
  #   |> Enum.map(&(Kernel.elem(&1, 0))) # Extract class name strings
  #   |> Enum.join(" ")
  # end

  @doc """
  Click me #button
  
  <button>Click me</button>
  """
  #defp preview(%Lofi.Element{children: [], texts, tags_list: ["button"]}, resolve_content) do
  defp preview(%Lofi.Element{children: [], tags_hash: %{"button" => {:flag, true}}}, %Lofi.Element{texts: texts, tags_hash: tags}, resolve_content) do
    class = flatten_classes [
      {"btn", true},
      {"active", Lofi.Tags.has_flag(tags, "active")},
      {"btn-lg", Lofi.Tags.has_flag(tags, "large")},
      {"btn-sm", Lofi.Tags.has_flag(tags, "small")},
      {"btn-block", Lofi.Tags.has_flag(tags, "block")},
      {
        cond do
          Lofi.Tags.has_flag(tags, "primary") -> "btn-primary"
          true -> "btn-secondary"
        end,
        true
      }
    ]

    Tag.content_tag(:button, Enum.join(texts, ""), class: class)
  end

  @doc """
  #button
  - First
  - Second
  
  <div class="btn-group">
    <button>First</button>
    <button>Second</button>
  </div>
  """
  defp preview(%Lofi.Element{tags_hash: %{"button" => {:flag, true}}}, %Lofi.Element{children: children, tags_hash: tags}, resolve_content) do
    class = flatten_classes [
      {"btn", true},
      {
        cond do
          Lofi.Tags.has_flag(tags, "primary") -> "btn-primary"
          true -> "btn-secondary"
        end,
        true
      }
    ]

    #Tag.content_tag(:button, Enum.join([""], ""), class: class)
    Tag.content_tag(:div, class: "btn-group") do
      children
      #|> Enum.map(&preview_element/1)
      |> Enum.map(fn (element) ->
        element = Map.update!(element, :tags, fn (child_tags) -> Map.merge(tags, child_tags) end)
        #|> &Map.update!(&1, :tags, &Map.merge(tags, &1))
        preview_element(element, [], resolve_content)
      end)
    end
  end

  defp input(type, texts, value \\ nil) do
    Tag.content_tag(:div, class: "form-group") do
      Tag.content_tag(:label, [
        Enum.join(texts, ""),
        " ",
        Tag.tag(:input, type: type, class: "form-control", value: value)
      ])
    end
  end

  defp textarea(texts, lines \\ 1) do
    Tag.content_tag(:div, class: "form-group") do
      Tag.content_tag(:label, [
        Enum.join(texts, ""),
        " ",
        Tag.content_tag(:textarea, '', class: "form-control", rows: lines)
      ])
    end
  end

  @doc """
  Enter email #email
  """
  defp preview(%Lofi.Element{tags_hash: %{"email" => {:flag, true}}}, %Lofi.Element{texts: texts}, resolve_content) do
    input("email", texts)
  end

  @doc """
  Phone number #phone
  """
  defp preview(%Lofi.Element{tags_hash: %{"phone" => {:flag, true}}}, %Lofi.Element{texts: texts}, resolve_content) do
    input("tel", texts)
  end

  @doc """
  Enter password #password
  """
  defp preview(%Lofi.Element{tags_hash: %{"password" => {:flag, true}}}, %Lofi.Element{texts: texts}, resolve_content) do
    input("password", texts)
  end

  @doc """
  Favorite number #number
  """
  defp preview(%Lofi.Element{tags_hash: %{"number" => {:flag, true}}}, %Lofi.Element{texts: texts, tags_hash: tags}, resolve_content) do
    input("number", texts, get_content_tag(tags, "default"))
  end

  @doc """
  Date of birth #date
  """
  defp preview(%Lofi.Element{tags_hash: %{"date" => {:flag, true}}}, %Lofi.Element{texts: texts, tags_hash: tags}, resolve_content) do
    input("date", texts)
  end

  @doc """
  Last signed in #time
  """
  defp preview(%Lofi.Element{tags_hash: %{"time" => {:flag, true}}}, %Lofi.Element{texts: texts, tags_hash: tags}, resolve_content) do
    value = cond do
      Lofi.Tags.has_flag(tags, "now") ->
        Time.utc_now
        |> Map.put(:microsecond, {0, 0}) # Remove extra precision that <input type="time"> does not like
      true ->
        nil
    end
    input("time", texts, value)
  end

  @doc """
  Enter message #text #lines: 6
  """
  defp preview(%Lofi.Element{tags_hash: %{"text" => {:flag, true}, "lines" => {:content, lines_element}}}, %Lofi.Element{texts: texts, tags_hash: tags}, resolve_content) do
    %{texts: [lines_string]} = lines_element
    textarea(texts, lines_string)
  end

  @doc """
  Enter message #text
  """
  defp preview(%Lofi.Element{tags_hash: %{"text" => {:flag, true}}}, %Lofi.Element{texts: texts, tags_hash: tags}, resolve_content) do
    input("text", texts, get_content_tag(tags, "default"))
  end

  @doc """
  #field
  
  <input>
  """
  defp preview(%Lofi.Element{tags_hash: %{"field" => {:flag, true}}}, %Lofi.Element{texts: texts, tags_hash: tags}, resolve_content) do
    type = cond do
      Lofi.Tags.has_flag(tags, "password") ->
        "password"
      Lofi.Tags.has_flag(tags, "email") ->
        "email"
      true ->
        "text"
    end

    input(type, texts, get_content_tag(tags, "default"))
  end

  @doc """
  Accept terms #choice
  
  <label><input type="checkbox"> Accept terms</label>
  """
  defp preview(%Lofi.Element{children: [], tags_hash: %{"choice" => {:flag, true}}}, %Lofi.Element{texts: texts, tags_hash: tags}, resolve_content) do
    Tag.content_tag(:label, [
      Tag.tag(:input, type: "checkbox"),
      " ",
      Enum.join(texts, "")
    ])
  end

  @doc """
  Multiple choice #choice
  - Australia
  - India
  - New Zealand
  
  <label>Multiple choice <select><option>Australia</option><option>India</option><option>New Zealand</option></select></label>
  """
  defp preview(%Lofi.Element{tags_hash: %{"choice" => {:flag, true}}}, %Lofi.Element{texts: texts, tags_hash: tags, children: children}, resolve_content) do
    Tag.content_tag(:label, [
      Enum.join(texts, ""),
      " ",
      Tag.content_tag(:select, class: "form-control") do
        Enum.map(children, fn (%Lofi.Element{texts: texts}) ->
          Tag.content_tag(:option, Enum.join(texts, ""))
        end)
      end
    ])
  end

  defp nav_item(%Lofi.Element{texts: texts, tags_hash: tags}) do
    class = flatten_classes [
      {"nav-item", true},
      {"active", Lofi.Tags.has_flag(tags, "active")}
    ]

    href = get_content_tag(tags, "link")
    
    Tag.content_tag(:li, class: class) do
      Tag.content_tag(:a, Enum.join(texts, ""), href: href, class: "nav-link")
    end
  end

  @doc """
  #nav
  - Australia
  - India
  - New Zealand
  """
  defp preview(%Lofi.Element{tags_hash: %{"nav" => {:flag, true}}}, %Lofi.Element{texts: texts, children: children}, resolve_content) do
    Tag.content_tag(:nav, [
      Enum.join(texts, ""),
      " ",
      Tag.content_tag(:div, class: "nav nav-pills") do
        Enum.map(children, &nav_item/1)
      end
    ])
  end

  @doc """
  Fallback to Primitive
  """
  defp preview(%Lofi.Element{children: []}, element, resolve_content) do
    Promotion.preview(element, element) || Primitives.preview(element, element, resolve_content) || HTML.html_escape("")
  end

  @doc """
  - Australia
  - India
  - New Zealand
  
  <ul>
    <li>Australia</li>
    <li>India</li>
    <li>New Zealand</li>
  </ul>
  """
  defp preview(%Lofi.Element{texts: texts, tags_hash: %{}}, %Lofi.Element{children: children, tags_hash: tags}, resolve_content) do
    tag = cond do
      Map.get(tags, "ordered") == {:flag, true} -> :ol
      true -> :ul
    end

    Tag.content_tag(:div, [
      Enum.join(texts), # Ignore text?
      " ",
      Tag.content_tag(tag) do
        Enum.map(children, fn (element) ->
          # TODO: pass components
          Tag.content_tag(:li, preview_element(element, [], resolve_content))
        end)
      end
    ])
  end


  defp component_tags_match(component_tags, tags) do
    matching_tags = Map.take(tags, Map.keys(component_tags))
    Kernel.map_size(component_tags) == Kernel.map_size(matching_tags)
  end

  # Check for custom component
  defp preview_element(element, components, resolve_content) do
    tags_hash = Map.get(element, :tags_hash)

    matching_component = components
    |> Enum.find(fn ({component_tags, _type, _body, _ingredients}) -> component_tags_match(component_tags, tags_hash) end)

    case matching_component do
      {_tags, :svg, body, ingredients} ->
        render_html_component(body, ingredients, element)
      {_tags, :html, body, ingredients} ->
        render_html_component(body, ingredients, element)
      _ ->
        preview(element, element, resolve_content)
    end

  end

  # defp preview_section([line | []], components) do
  #   # Handle single so no wrapper <div>
  #   preview_element(line, components)
  # end

  defp preview_section(lines, components, resolve_content) do
    html_lines = Enum.map(lines, &preview_element(&1, components, resolve_content))

    Tag.content_tag(:div, html_lines, class: "mb-3")
  end

  # FIXME: move references to Component: parse beforehand
  defp parse_component_entry(%Component{tags: tags_s, type: type_n, body: body, ingredients: ingredients}) do
    %Lofi.Element{tags_hash: tags} = Lofi.Parse.parse_element(tags_s)
    type = LofiPlay.Content.Component.Type.to_atom(type_n)
    {tags, type, body, ingredients}
  end

  defp parse_components_entries(component_entries) do
    component_entries
    |> Enum.map(&parse_component_entry/1)
  end

  defp get_ingredient_value(ingredients, key_path) do
    case Enum.find(ingredients, fn({name, _value}) ->
      [name] == key_path
    end) do
      nil ->
        "@!#{Enum.join(key_path, ".")}"
      {_name, {_type, default, []}} ->
        default || ""
      {_name, {_type, _default, children}} ->
        Enum.join(Enum.random(children).texts)
    end
  end

  def preview_sections(sections, ingredients, components, values) do
    resolve_mention = fn(key_path) ->
      case Map.fetch(values, key_path) do
        {:ok, value} -> value
        _ -> get_ingredient_value(ingredients, key_path)
      end
    end

    resolve_content = fn(texts, mentions) ->
      Lofi.Resolve.resolve_content(texts, mentions, resolve_mention)
    end

    sections
    |> Enum.map(&preview_section(&1, components, resolve_content))
  end

  def preview_text(text, ingredients_s, component_entries \\ [], values \\ %{}) when is_binary(text) do
    ingredients = ingredients_s
    |> LofiPlay.Preview.Lofi.parse_ingredients

    components = component_entries
    |> parse_components_entries

    Lofi.Parse.parse_sections(text)
    |> preview_sections(ingredients, components, values)
  end
end