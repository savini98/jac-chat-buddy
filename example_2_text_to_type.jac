import:py from jaclang.core.llms, Anthropic;

glob llm = Anthropic(model_name="claude-3-sonnet-20240229");

obj 'Employer'
Employer {
    has employer_name: 'Employer Name': str,
        location: 'Location': str;
}

obj 'Person'
Person {
    has name: 'Name': str,
        age: 'Age': int,
        employer: 'Employer': Employer,
        job: 'Job': str;
}

with entry {
    info: "Person's Information": str = "Sarah is a 35-year-old marketing executive based in New York City."
                                        "She specializes in digital marketing strategies and works for AdvertiseMint.";
    person = Person(by llm(incl_info=(info)));
    print(f"Person's name is {person.name} and works at {person.employer.employer_name} which is located in {person.employer.location}.");
}