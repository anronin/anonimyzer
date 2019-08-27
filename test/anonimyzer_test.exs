defmodule AnonimyzerTest do
  use ExUnit.Case
  doctest Anonimyzer

  describe "anonymize/2 for Map" do
    test "when input data and selectors are valid" do
      data = %{
        customer: %{
          name: "Andrew",
          surname: "Yudin",
          email: "andrew@channex.io"
        },
        checkin_date: "2019-02-20",
        checkout_date: "2019-02-21"
      }

      profile = %{
        kind: Anonimyzer.Map,
        selectors: [
          {"customer/name", :mask},
          {"customer/surname", :mask},
          {"customer/email", :drop}
        ]
      }

      assert Anonimyzer.anonymize(data, profile) == %{
               customer: %{
                 name: "A*@#$w",
                 surname: "Y*@#n"
               },
               checkin_date: "2019-02-20",
               checkout_date: "2019-02-21"
             }
    end

    test "when input data and selectors are invalid" do
      data = %{customer: %{name: "Andrew"}, checkin_date: "2019-02-20"}
      profile = %{kind: Anonimyzer.Map, selectors: [{"custom/name", :mask}]}

      assert Anonimyzer.anonymize(data, profile) ==
               {:error,
                [
                  %{
                    error: "Selector with anonymization method: :mask didn't match the data",
                    path: "custom/name"
                  }
                ]}
    end
  end
end
