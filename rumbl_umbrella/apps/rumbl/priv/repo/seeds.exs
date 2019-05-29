# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Rumbl.Repo.insert!(%Rumbl.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Rumbl.Accounts.User
alias Rumbl.Accounts
alias Rumbl.Multimedia

user = Accounts.get_user_by_email("oscarjg19@gmail.com")

if (!user) do
  user = User.registration_changeset(
    %User{},
    %{
      :name     => "Oscar",
      :username => "oscarjg",
      :credential => %{
        :email    => "oscarjg19@gmail.com",
        :password => "123456"
      }
    }
  )

  Rumbl.Repo.insert!(user)
end

for category_name <- ~w(Action Gaming Sports Drama Romance Sci-fi) do
  Multimedia.create_category(category_name)
end