Fabricator(:session) do
  login 5.hours.ago
  logout 1.hours.ago
  idle 1800
end