// nnoremap � :echo lh#cpp#AnalysisLib_Function#AnalysePrototype(lh#cpp#AnalysisLib_Function#GetFunctionPrototype(line('.'), 0))<cr>
// nnoremap � :echo lh#cpp#AnalysisLib_Function#GetFunctionPrototype(line('.'), 0)<cr>

void f(int)
{
    printf(toto);
}
class Toto
{
    typedef tutu;

    Toto(Toto const& rhs);
    Toto(Ttiti const& rhs, int z=42, T t=T());
    Toto(Ttiti const& rhs,
	    float z=42);
    ~Toto();
    virtual ~Toto();
    Toto& operator=(Toto const& rhs);
    Toto& operator*(Toto const& rhs);
    Toto* operator*(Toto const& rhs);
    void operator*(Toto const& rhs);
    void operator+(Toto const& rhs);
    std::ostream & operator<<(std::ostream &os, const Toto& toto);
    operator int() const;
    operator const T*() const;
    Titi * f();
    Titi & g();
    virtual void f(Titi * titi) const;
    static void f(Titi const* titi);
    static s();
    void foo(toto t=42, titi r, tutu z=f()) throw();
    void foo(toto t=42, titi r, tutu z=f()) throw(foo);
    void foo(toto t=42, titi r, tutu z=f()) throw(foo, bar);
    void foo(toto t=42, std::string const& s, char * p, int[] i, titi r, tutu z=f()) const throw(foo, bar);
    int foo(toto t=42, std::string const&, char * p, int[] i, std::vector<short>, titi r, tutu z=f()) const throw(foo, bar);
};

namespace NS1 { namespace NS2 {
    int foo; // -> echo lh#cpp#AnalysisLib_Class#CurrentScope(line('.'), '##')
} }

void NS1::NS2::foo(toto t=42, int, std::string const& s, char * p, int[] i, titi r, tutu z=f()) const throw(foo, bar);

/*===========================================================================*/
/*===================================[ t ]===================================*/
/*===========================================================================*/

Toto::~Toto()
{
    
}

void Toto::operator+(Toto const& rhs)
{
}

Toto* Toto::operator*(Toto const& rhs)
{
}

Titi & Toto::g()
{
}

Titi * Toto::f()
{
}

Toto& Toto::operator=(Toto const& rhs)
{
    while (toto = 42) {
    if (toto = 42) 
	foo == 42;
	
    }��
}
