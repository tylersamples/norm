defmodule Norm.MismatchError do
  defexception [:message]

  def exception(errors) do
    msg =
      errors
      |> Enum.map(&Norm.Conformer.error_to_msg/1)
      |> Enum.join("\n")

    %__MODULE__{message: "Could not conform input:\n" <> msg}
  end
end

defmodule Norm.GeneratorLibraryError do
  defexception [:message]

  def exception(_) do
    %__MODULE__{
      message: "In order to use generators please include `stream_data` as a dependency"
    }
  end
end

defmodule Norm.GeneratorError do
  defexception [:message]

  def exception(predicate) do
    msg = "Unable to create a generator for: #{predicate}"
    %__MODULE__{message: msg}
  end
end

defmodule Norm.SpecError do
  defexception [:message]
  alias Norm.Spec
  alias Norm.Schema

  def exception(details) do
    %__MODULE__{message: msg(details)}
  end

  defp msg({:selection, key, schema}) do
    """
    key: #{format(key)} was not found in schema:
    #{format(schema)}
    """
  end

  defp format(val, indentation \\ 0)

  defp format({key, spec_or_schema}, i) do
    format(key, i) <> " => " <> format(spec_or_schema, i + 1)
  end

  defp format(atom, _) when is_atom(atom), do: ":#{atom}"
  defp format(str, _) when is_binary(str), do: ~s|"#{str}"|
  defp format(%Spec{predicate: pred}, _), do: "spec(#{pred})"

  defp format(%Schema{specs: specs}, i) do
    specs =
      specs
      |> Enum.map(&format(&1, i))
      |> Enum.map(&pad(&1, (i + 1) * 2))
      |> Enum.join("\n")

    "%{\n" <> specs <> "\n" <> pad("}", i * 2)
  end

  defp format(element, _) when is_list(element) do
    Enum.each(element, &Enum.join(&1, ", "))
  end

  defp pad(str, 0), do: str
  defp pad(str, i), do: " " <> pad(str, i - 1)
end
