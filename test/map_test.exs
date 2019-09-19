defmodule Miss.MapTest do
  use ExUnit.Case, async: true

  alias Miss.Map, as: Subject

  defmodule Post do
    defstruct [:title, :text, :date, :author, comments: []]
  end

  defmodule Author do
    defstruct [:name, :metadata]
  end

  defmodule Comment do
    defstruct [:text]
  end

  defmodule Metadata do
    defstruct [:atom, :boolean, :decimal, :float, :integer]
  end

  describe "from_nested_struct/2" do
    setup do
      struct = %Post{
        title: "My post",
        text: "Something really interesting",
        date: ~D[2010-09-01],
        author: %Author{
          name: "Pedro Bonamides",
          metadata: %Metadata{
            atom: :my_atom,
            boolean: true,
            decimal: Decimal.new("456.78"),
            float: 987.54,
            integer: 2_345_678
          }
        },
        comments: [
          %Comment{text: "Comment one"},
          %Comment{text: "Comment two"}
        ]
      }

      {:ok, struct: struct}
    end

    test "converts to map going through all nested structs", %{struct: struct} do
      expected_map = %{
        title: "My post",
        text: "Something really interesting",
        date: %{calendar: Calendar.ISO, day: 1, month: 9, year: 2010},
        author: %{
          name: "Pedro Bonamides",
          metadata: %{
            atom: :my_atom,
            boolean: true,
            decimal: %{coef: 45678, exp: -2, sign: 1},
            float: 987.54,
            integer: 2_345_678
          }
        },
        comments: [
          %{text: "Comment one"},
          %{text: "Comment two"}
        ]
      }

      assert Subject.from_nested_struct(struct) == expected_map
    end

    test "when transform is given with functions," <>
           "converts to map going through all nested structs " <>
           "using the transformation functions on the given struct types",
         %{struct: struct} do
      expected_map = %{
        title: "My post",
        text: "Something really interesting",
        date: "2010-09-01",
        author: %{
          name: "Pedro Bonamides",
          metadata: %{
            atom: :my_atom,
            boolean: true,
            decimal: 456.78,
            float: 987.54,
            integer: 2_345_678
          }
        },
        comments: ["Comment one", "Comment two"]
      }

      assert Subject.from_nested_struct(
               struct,
               [
                 {Date, &to_string/1},
                 {Decimal, &Decimal.to_float/1},
                 {Comment, fn %{text: text} -> text end}
               ]
             ) == expected_map
    end

    test "when transform is given with :skip," <>
           "converts to map going through all nested structs " <>
           "skiping the conversion for the given struct types",
         %{struct: struct} do
      expected_map = %{
        title: "My post",
        text: "Something really interesting",
        date: ~D[2010-09-01],
        author: %{
          name: "Pedro Bonamides",
          metadata: %{
            atom: :my_atom,
            boolean: true,
            decimal: Decimal.new("456.78"),
            float: 987.54,
            integer: 2_345_678
          }
        },
        comments: [
          %{text: "Comment one"},
          %{text: "Comment two"}
        ]
      }

      assert Subject.from_nested_struct(
               struct,
               [
                 {Date, :skip},
                 {Decimal, :skip}
               ]
             ) == expected_map
    end
  end
end
