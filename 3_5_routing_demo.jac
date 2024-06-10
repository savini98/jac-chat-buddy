import:py from jaclang.core.llms, OpenAI;

glob llm = OpenAI(model_name="gpt-3.5-turbo");

glob experts = ['DOCTOR','PLUMBER','ELECTRICIAN','MECHANIC','LAWYER','NONE'];

enum 'expert who can solve the problem'
experts_enum {
    DOCTOR: 'A person who is qualified to treat people who are ill' = 'Doctor',
    PLUMBER: 'A person who fits and repairs the pipes, fittings, and other apparatus of water supply, sanitation, or heating systems' = 'Plumber',
    ELECTRICIAN: 'A person who installs and maintains electrical equipment' = 'Electrician',
    MECHANIC: 'A person who repairs and maintains machinery' = 'Mechanic',
    LAWYER: 'A person who practices or studies law' = 'Lawyer',
    NONE: 'No expert found' = 'None'
}

can assign_to_expert_1 (
    expert_list: 'list of available experts':str,
    problem: 'problem to be solved by an expert':str
    ) -> 'expert can be be only from expert list':str by llm();

can 'choose an EXPERT who can potentially solve the given problem'
assign_to_expert_2 (
    problem: 'problem to be solved by an expert':str
    ) -> 'expert can be only from existing expert enum objects':experts_enum by llm();

with entry {
    print(
        type1 := assign_to_expert_1(
            expert_list=experts,
            problem="I need help with my door squeaking"
        )
    );
    print(type(type1));

    print(
        type2 := assign_to_expert_2(
            problem="I need help with my door squeaking"
        )
    );

    print(type(type2));
}